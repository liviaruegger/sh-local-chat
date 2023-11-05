#!/bin/bash


# TODO - INSERIR CABEÇALHO AQUI


# INFORMAÇÕES BÁSICAS DO BOT ---------------------------------------------------

TOKEN="6861449526:AAHL5GIauHX3WM9roiSkQhUhi6UT11qO5jE"
CHAT_ID="1746769700"

URL="https://api.telegram.org/bot${TOKEN}/sendMessage?chat_id=${CHAT_ID}"


# CONSTANTES E VARIÁVEIS GLOBAIS -----------------------------------------------

QUEBRA_DE_LINHA=$'\n'

USUARIO_ATUAL=""
ENCERRAR=0


# FUNÇÕES AUXILIARES -----------------------------------------------------------

function msg_telegram {
    curl -s --data "text=$1" $URL 1>/dev/null    
}


# IDENTIFICAÇÃO DO MODO (CLIENTE OU SERVIDOR) ----------------------------------

MODO=$1

# Checar se o argumento é válido
if ! [ "$MODO" = "servidor" ] && ! [ "$MODO" = "cliente" ]; then
    echo "ERRO: argumento '${MODO}' é inválido; utilize 'servidor' ou 'cliente'"
    exit 1
fi

# Testando
echo "executando modo: ${MODO}"
msg_telegram "executando modo: ${MODO}"


# IMPLEMENTAÇÃO DO SERVIDOR ----------------------------------------------------

# Inicializar o servidor

if [ "$MODO" = "servidor" ]; then
    CONTADOR_DE_TEMPO=0
    TEMPO_FILE=$(mktemp /tmp/tempo.XXXXXX)

    # Loop para contar o tempo desde que o servidor foi iniciado
    while [ 1 ]; do
        sleep 1
        ((CONTADOR_DE_TEMPO++))
        echo $CONTADOR_DE_TEMPO > $TEMPO_FILE
    done &

    TEMPO_BG=$!

    # Inicializar diretorio para arquivos de usuários
    USUARIOS=$(mktemp -d  /tmp/usuarios-XXXXXX)
    echo "" > ${USUARIOS}/usuarios_logados

    # Enviar a lista de usuários para o Telegram a cada 60 segundos
    HEADER="Lista de usuários conectados:${QUEBRA_DE_LINHA}"
    while [ 1 ]; do
        msg_telegram "${HEADER}$(cat ${USUARIOS}/usuarios_logados)"
        sleep 60
    done &

    LISTAR_BG=$!
fi

# Comandos disponíveis: list, time, reset, quit

function time {
    cat $TEMPO_FILE
}

function reset {
    rm -r $USUARIOS

    # Inicializar novo diretorio para arquivos de usuários
    USUARIOS=$(mktemp -d  /tmp/usuarios-XXXXXX)
    echo "" > ${USUARIOS}/usuarios_logados
}


# IMPLEMENTAÇÃO DO CLIENTE -----------------------------------------------------

# Comandos disponíveis: create, passwd, login, logout, list, msg, quit

function create {
    usuario=$(echo $line | cut -d ' ' -f 2)
    senha=$(echo $line | cut -d ' ' -f 3)
    
    # TODO - implementar

    # MOCK
    echo "mock: executando create"
    echo "usuario: ${usuario}"
    echo "senha: ${senha}"
}

function passwd {
    usuario=$(echo $line | cut -d ' ' -f 2)
    senha_antiga=$(echo $line | cut -d ' ' -f 3)
    senha_nova=$(echo $line | cut -d ' ' -f 4)

    # TODO - implementar

    # MOCK
    echo "mock: executando passwd"
    echo "usuario: ${usuario}"
    echo "senha_antiga: ${senha_antiga}"
    echo "senha_nova: ${senha_nova}"
}

function login {
    usuario=$(echo $line | cut -d ' ' -f 2)
    senha=$(echo $line | cut -d ' ' -f 3)

    # TODO - implementar

    # MOCK
    echo "mock: executando login"
    echo "usuario: ${usuario}"
    echo "senha: ${senha}"
}

function logout {
    # TODO - implementar
    echo "mock: executando logout"
}

function msg {
    usuario=$(echo $line | cut -d ' ' -f 2)
    mensagem=$(echo $line | cut -d ' ' -f 3-)

    # TODO - implementar

    # MOCK
    echo "mock: executando msg"
    echo "usuario: ${usuario}"
    echo "mensagem: ${mensagem}"
}


# FUNÇÕES GERAIS ---------------------------------------------------------------

function list {
    if ! [ "$(cat ${USUARIOS}/usuarios_logados)" = "" ]; then
        cat "${USUARIOS}/usuarios_logados"
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

        # Remover arquivos temporários
        rm -r $USUARIOS
        rm $TEMPO_FILE
    fi

    msg_telegram "encerrando ${MODO}${QUEBRA_DE_LINHA}$(date)"

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
    if [[ "${COMANDOS_VALIDOS[@]}" =~ "${comando}" ]]; then
        $comando
    else
        echo "ERRO: comando inválido"
    fi
done

exit 0