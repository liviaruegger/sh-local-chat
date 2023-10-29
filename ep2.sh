#!/bin/bash


# TODO - INSERIR CABEÇALHO AQUI


# INFORMAÇÕES BÁSICAS DO BOT ---------------------------------------------------

TOKEN="6861449526:AAHL5GIauHX3WM9roiSkQhUhi6UT11qO5jE"
CHAT_ID="1746769700"

URL="https://api.telegram.org/bot${TOKEN}/sendMessage?chat_id=${CHAT_ID}"

# Testar o envio de mensagem:
# curl -s --data "text=ola, mundo!" $URL 1>/dev/null


# VARIÁVEIS GLOBAIS ------------------------------------------------------------

logado=0
usuario=""
encerrar=0


# FUNÇÕES AUXILIARES -----------------------------------------------------------

function msg_telegram {
    curl -s --data "text=$1" $URL 1>/dev/null    
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


# IMPLEMENTAÇÃO DO CLIENTE -----------------------------------------------------


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
    
    IFS=" "
    read COMANDO

    # TODO - Como ler os argumentos do comando?

    # Executa apenas se COMANDO estiver em COMANDOS_VALIDOS
    if [[ " ${COMANDOS_VALIDOS[@]} " =~ " ${COMANDO} " ]]; then
        echo "comando válido"
        $COMANDO  # executa comando
    else
        echo "ERRO: comando inválido"
    fi
done

exit 0