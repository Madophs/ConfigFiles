if [[ -x $(which minikube) ]]
then
    alias kc='minikube kubectl --'
    alias kcip='minikube ip'
else
    alias kc='kubectl'
fi

