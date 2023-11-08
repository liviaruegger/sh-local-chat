#!/bin/bash


# TODO - INSERIR CABEÇALHO AQUI


# INFORMAÇÕES BÁSICAS DO BOT ---------------------------------------------------

TOKEN="6861449526:AAHL5GIauHX3WM9roiSkQhUhi6UT11qO5jE"
CHAT_ID="1746769700"

URL="https://api.telegram.org/bot${TOKEN}/sendMessage?chat_id=${CHAT_ID}"


# CONSTANTES E VARIÁVEIS GLOBAIS -----------------------------------------------

NEWLINE=$'\n'

DIRETORIO="/tmp/arquivos_servidor"
CADASTRO="${DIRETORIO}/usuarios_cadastrados"
LOGADOS="${DIRETORIO}/usuarios_logados"

USUARIO_ATUAL=""
ENCERRAR=0


# FUNÇÕES AUXILIARES -----------------------------------------------------------

function msg_telegram {
    curl -s --data "text=$1" $URL 1>/dev/null    
}


# IDENTIFICAÇÃO DO MODO (CLIENTE OU SERVIDOR) ----------------------------------

MODO=$1

# Checar se o argumento é válido
if [ "$MODO" != "servidor" ] && [ "$MODO" != "cliente" ]; then
    echo "ERRO: argumento '${MODO}' é inválido; utilize 'servidor' ou 'cliente'"
    exit 1
fi


# IMPLEMENTAÇÃO DO SERVIDOR ----------------------------------------------------

# Inicializar o servidor

if [ "$MODO" = "servidor" ]; then
    msg_telegram "SERVIDOR INICIADO EM:${NEWLINE}$(date)"

    CONTADOR_DE_TEMPO=0
    TEMPO=$(mktemp /tmp/tempo.XXXXXX)

    # Loop para contar o tempo desde que o servidor foi iniciado
    while [ 1 ]; do
        sleep 1
        ((CONTADOR_DE_TEMPO++))
        echo $CONTADOR_DE_TEMPO > $TEMPO
    done &

    TEMPO_BG=$!

    # Inicializar diretorio para arquivos de usuários
    mkdir $DIRETORIO
    touch $CADASTRO
    touch $LOGADOS

    # Enviar a lista de usuários para o Telegram a cada 60 segundos
    while [ 1 ]; do
        msg_telegram "USUÁRIOS CONECTADOS:${NEWLINE}$(cat $LOGADOS)"
        sleep 60
    done &

    LISTAR_BG=$!
fi

# Comandos disponíveis: list, time, reset, quit

function time {
    cat $TEMPO
}

function reset {
    rm -r $DIRETORIO

    # Inicializar novo diretorio para arquivos de usuários
    mkdir $DIRETORIO
    touch $CADASTRO
    touch $LOGADOS
}


# IMPLEMENTAÇÃO DO CLIENTE -----------------------------------------------------

# Comandos disponíveis: create, passwd, login, logout, list, msg, quit

function create {
    usuario=$(echo $line | cut -d ' ' -f 2)
    senha=$(echo $line | cut -d ' ' -f 3)

    cadastrado=$(grep "^${usuario} " $CADASTRO)

    if [ "$cadastrado" = "" ]; then
        echo "${usuario} ${senha}" >> $CADASTRO
    else
        echo "ERRO: usuário já cadastrado"
    fi
}

function passwd {
    usuario=$(echo $line | cut -d ' ' -f 2)
    senha_antiga=$(echo $line | cut -d ' ' -f 3)
    senha_nova=$(echo $line | cut -d ' ' -f 4)

    cadastrado=$(grep "^${usuario} " $CADASTRO)
    
    if [ "$cadastrado" = "" ]; then
        echo "ERRO: usuário não cadastrado"
    elif [ "$senha_antiga" != "$(echo $cadastrado | cut -d ' ' -f 2)" ]; then
        echo "ERRO: senha incorreta"
    else
        # Substitui a senha antiga pela nova no arquivo de usuários cadastrados
        sed -i "s/^${usuario} .*/${usuario} ${senha_nova}/" $CADASTRO
    fi
}

function login {
    usuario=$(echo $line | cut -d ' ' -f 2)
    senha=$(echo $line | cut -d ' ' -f 3)

    cadastrado=$(grep "^${usuario} " $CADASTRO)
    logado=$(grep -x $usuario $LOGADOS)

    if [ "$USUARIO_ATUAL" != "" ]; then
        echo "ERRO: você já está logado como ${USUARIO_ATUAL}"
    elif [ "$cadastrado" = "" ]; then
        echo "ERRO: usuário não cadastrado"
    elif [ "$logado" != "" ]; then
        echo "ERRO: usuário já está logado"
    elif [ "$senha" != "$(echo $cadastrado | cut -d ' ' -f 2)" ]; then
        echo "ERRO: senha incorreta"
        msg_telegram "<${usuario}> errou a senha em:${NEWLINE}$(date)"
    else
        echo $usuario >> $LOGADOS
        USUARIO_ATUAL=$usuario

        msg_telegram "<${usuario}> logou com sucesso em:${NEWLINE}$(date)"

        # Criar named pipe para receber mensagens
        mkfifo $DIRETORIO/$USUARIO_ATUAL
        while [ 1 ]; do
            cat $DIRETORIO/$USUARIO_ATUAL
        done &
        CHAT_BG=$!
    fi
}

function logout {
    if [ "$USUARIO_ATUAL" != "" ]; then
        kill -15 $CHAT_BG  # encerra o processo do chat
        rm $DIRETORIO/$USUARIO_ATUAL  # remove o named pipe

        # Deleta a linha com o usuário atual do arquivo de usuários logados
        sed -i "/^${USUARIO_ATUAL}\$/d" $LOGADOS

        msg_telegram "<${USUARIO_ATUAL}> fez logout em:${NEWLINE}$(date)"
        
        USUARIO_ATUAL=""
    else
        echo "ERRO: você não está logado"
    fi
}

function msg {
    if [ "$USUARIO_ATUAL" = "" ]; then
        echo "ERRO: você não está logado"
        return
    fi

    usuario=$(echo $line | cut -d ' ' -f 2)
    mensagem=$(echo $line | cut -d ' ' -f 3-)

    if [ "$usuario" = "$USUARIO_ATUAL" ]; then
        echo "ERRO: você não pode mandar mensagem para si mesmo"
    elif [ "$(grep -x $usuario $LOGADOS)" = "" ]; then
        echo "ERRO: usuário ${usuario} não está logado"
    else
        echo "[Mensagem de ${USUARIO_ATUAL}]: ${mensagem}" > $DIRETORIO/$usuario
        echo -n "${MODO}> " > $DIRETORIO/$usuario
    fi
}


# FUNÇÕES GERAIS ---------------------------------------------------------------

function list {
    if [ "$MODO" = "cliente" ] && [ "$USUARIO_ATUAL" = "" ]; then
        echo "ERRO: você não está logado"
    else
        cat $LOGADOS
    fi
}

function quit {
    if [ "$MODO" = "cliente" ]; then
        if ! [ "$USUARIO_ATUAL" = "" ]; then
            logout
        fi
    else
        # Matar processos em background
        kill -15 ${TEMPO_BG}
        kill -15 ${LISTAR_BG}

        # Remover arquivos
        rm -r $DIRETORIO
        rm $TEMPO

        msg_telegram "SERVIDOR ENCERRADO EM:${NEWLINE}$(date)"
    fi

    ENCERRAR=1
}


# RECEBER E EXECUTAR COMANDOS --------------------------------------------------

# Define quais são os comandos válidos de acordo com o modo
if [ "$MODO" = "servidor" ]; then
    COMANDOS_VALIDOS=("list" "time" "reset" "quit")
else
    COMANDOS_VALIDOS=("create" "passwd" "login" "logout" "list" "msg" "quit")
fi

# Ler comandos do usuário até receber o comando quit
while [ $ENCERRAR = 0 ]; do
    echo -n "${MODO}> "

    read line

    comando=$(echo $line | cut -d ' ' -f 1)

    # Executa apenas se o comando digitado estiver em COMANDOS_VALIDOS
    if [[ " ${COMANDOS_VALIDOS[@]} " =~ " ${comando} " ]]; then
        $comando
    else
        echo "ERRO: comando inválido"
    fi
done

exit 0