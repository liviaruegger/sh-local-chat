#!/bin/bash

# ------------------- EP02 -------------------
# MAC0216 - Técnicas de Programação I - 2s2023
# --------------------------------------------
# 
# === AUTORA ===
# 
# Ana Lívia Rüegger Saldanha
# NUSP: 8586691
# ana.saldanha@usp.br
# 
# === DESCRIÇÃO ===
# 
# Este projeto, realizado como Exercício Programa para a disciplina MAC0216 do
# IME-USP, consiste em um sistema de chat que permite a comunicação local de
# usuários logados no mesmo computador. O sistema apresenta um modo servidor -
# que deve ser invocado uma vez para iniciar o sistema - e um modo cliente - que
# pode ser invocado em diversos terminais, permitindo o uso simultâneo por
# vários usuários.
# 
# Além do sistema de chat cliente/servidor, o script ep2.sh também implementa
# funcionalidades para monitoramento do sistema, enviando alertas via bot do
# Telegram.
# 
# === COMO EXECUTAR ===
# 
# Note que o sistema foi implementado em um unico arquivo ep2.sh, portanto
# deve-se especificar a execução de servidor ou cliente através de argumentos
# de linha de comando.
# 
# O servidor de chat deve ser iniciado antes de qualquer cliente. Para executar
# o servidor, basta invocá-lo uma única vez, no shell, da seguinte forma:
# $   ./ep2.sh servidor
# 
# Quanto ao(s) cliente(s), para cada terminal em que se deseje usar o sistema de
# chat, deve-se invocar o script em modo cliente através do comando:
# $   ./ep2.sh cliente
# 
# As instruções acima consideram que o script já está com permissão de execução
# e está localizado no diretório local.
# 
# === TESTES ===
# 
# Durante a execução, o sistema de chat disponibiliza os seguintes comandos:
# 
# --- COMANDOS DO SERVIDOR ---
# 
# > list  -   Lista os nomes de todos os usuários logados.
# 
# > time  -   Informa o intervalo de tempo, em segundos, desde que o servidor
#             foi iniciado.
# 
# > reset -   Remove todos os usuários que foram criados nesta instância de
#             execução atual do servidor.
# 
# > quit  -   Finaliza o servidor.
# 
# --- COMANDOS DO CLIENTE --- 
# 
# > create usuario senha          -   Cria um novo usuário de nome <usuario> e
#                                     senha <senha>.
# 
# > passwd usuario antiga nova    -   Modifica a senha do usuário <usuario> de
#                                     <antiga> para <nova>.
# 
# > login usuario senha           -   Loga com o usuário de nome <usuario> com
#                                     a senha <senha>.
# 
# > logout                        -   Desloga do sistema, sem encerrar a
#                                     execução do cliente.
# 
# > list                          -   Lista os nomes de todos os usuários
#                                     logados.
# 
# > msg usuario mensagem          -   Escreve na tela do usuário <usuario> a
#                                     mensagem <mensagem>.
# 
# > quit                          -   Encerra a execução do cliente. Caso o
#                                     usuário não tenha feito logout, faz logout
#                                     antes de encerrar.
# 
# O programa pode ser testado em sistema operacional Linux da seguinte maneira:
# 
# Um servidor deve ser iniciado em um terminal; em outros terminais, quantos
# forem considerados necessários, o script deve ser invocado em modo cliente.
# Após o cadastro e login de usuários, pode-se realizar a troca de mensagens
# entre usuários logados, assim como a execução de todos os outros comandos
# disponíveis, listados acima.
# 
# Também podem ser testadas situações nas quais se espera uma mensagem de erro:
# cadastro de usuário com mesmo nome, tentativa de login com senha incorreta,
# login de usuário não cadastrado, login com usuário já logado, execução de
# comandos que exigem login sem que o usuário esteja logado. Todos esses erros
# serão devidamente tratados e informados.
# 
# Note que apenas um servidor deve ser invocado por vez, não sendo esperada a
# execução de mais de um servidor simultaneamente. Além disso, pode-se observar
# que, após encerramento do servidor, todas as informações da sessão serão
# apagadas, desde que isso seja realizado corretamente através do comando quit.
# 
# Para testar o monitoramento via Telegram, é necessário que se tenha acesso ao
# bot, que pode ser alterado no início do script, através das variáveis TOKEN
# (referente ao bot) e CHAT_ID (referente ao chat).
# 
# === DEPENDÊNCIAS ===
# 
# Bash:   GNU bash, version 5.0.17(1)-release (x86_64-pc-linux-gnu)
# SO:     x86_64 GNU/Linux


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