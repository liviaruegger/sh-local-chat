#!/bin/bash


# TODO - INSERIR CABEÇALHO AQUI


# INFORMAÇÕES BÁSICAS DO BOT ---------------------------------------------------

TOKEN="6861449526:AAHL5GIauHX3WM9roiSkQhUhi6UT11qO5jE"
CHAT_ID="1746769700"

URL="https://api.telegram.org/bot${TOKEN}/sendMessage?chat_id=${CHAT_ID}"


# VARIÁVEIS GLOBAIS ------------------------------------------------------------

logado=0
usuario=""
encerrar=0


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


# FUNÇÕES GERAIS ---------------------------------------------------------------

function list {
    # TODO - implementar
    echo "mock: executando list"
}

function quit {
    # TODO - se for cliente, faz logout caso o user esteja logado
    # if ["$MODO" = "cliente"]; then
    #     if ["$logado" = "1"]; then
    #         # logout
    #     fi
    # fi

    msg_telegram "encerrando ${MODO}"

    encerrar=1
}


# IMPLEMENTAÇÃO DO SERVIDOR ----------------------------------------------------

# Comandos disponíveis: list, time, reset, quit

function time {
    # TODO - implementar
    echo "mock: executando time"
}

function reset {
    # TODO - implementar
    echo "mock: executando reset"
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


# RECEBER E EXECUTAR COMANDOS --------------------------------------------------

# Define quais são os comandos válidos de acordo com o modo
if [ "$MODO" = "servidor" ]; then
    COMANDOS_VALIDOS=("list" "time" "reset" "quit")
else
    COMANDOS_VALIDOS=("create" "passwd" "login" "logout" "list" "msg" "quit")
fi

# Ler comandos do usuário até receber o comando quit
while [ $encerrar = 0 ]; do
    echo -n "${MODO}> "

    read line

    COMANDO=$(echo $line | cut -d ' ' -f 1)

    # Executa apenas se COMANDO estiver em COMANDOS_VALIDOS
    if [[ " ${COMANDOS_VALIDOS[@]} " =~ " ${COMANDO} " ]]; then
        echo "comando válido"
        $COMANDO  # executa comando
    else
        echo "ERRO: comando inválido"
    fi
done

exit 0