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

    # Inicializar o arquivo de usuários logados
    echo "" > /tmp/usuarios_logados
fi

# Comandos disponíveis: list, time, reset, quit

function time {
    cat $TEMPO_FILE
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


# FUNÇÕES GERAIS ---------------------------------------------------------------

function list {
    if ! [ "$(cat /tmp/usuarios_logados)" = "" ]; then
        cat /tmp/usuarios_logados
    fi
}

function quit {
    # TODO - se for cliente, faz logout caso o user esteja logado
    # if ["$MODO" = "cliente"]; then
    #     if ["$logado" = "1"]; then
    #         # logout
    #     fi
    # fi

    msg_telegram "encerrando ${MODO}"

    kill -15 ${TEMPO_BG}

    encerrar=1
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
    if [[ "${COMANDOS_VALIDOS[@]}" =~ "${COMANDO}" ]]; then
        $COMANDO  # executa comando
    else
        echo "ERRO: comando inválido"
    fi
done

exit 0