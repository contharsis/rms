# RMS - Minecraft Server Runner - Put everything in an environment loader (e.g. ~/.bashrc) then reload it (e.g. source ~/.bashrc)

# Commands
# rms - Run minecraft server - 2 Arguments - Modpack ; q (Optional)
# cmsc - Create minecraft servers configs
# initms - Load servers configs into the environment
# addms - Add server config - 1 Argument - Modpack
# remms - Remove server config - 1 Argument - Modpack
# st - Check server status
# ss - Stop server

unset valid_modpacks
unset dirs
unset params
unset jars
unset instancespath

declare -Ag valid_modpacks
declare -Ag dirs
declare -Ag params
declare -Ag jars
instancespath=''

mpcheck(){
        local result='1'
        local caller
        caller=$1

        if [ "${#valid_modpacks[@]}" = '0' ]; then
                echo "No modpacks loaded"
                result='0'
        elif [ "$2" = '' ]; then
                echo "Modpack can't be empty"
                result='0'
        elif ! [ -n "${valid_modpacks[$2]}" ]; then
                echo "Error: Invalid modpack choice, valid ones are: ${!valid_modpacks[@]}"
                result='0'
        fi

        eval $caller="'$result'"
}

cmsc(){
        local choice=''

        instancespath="/home/$(whoami)/Desktop/serverconfigs/"

        if [ -d "$instancespath" ]; then
                instancespath+="instances.txt"

                if [ -f "${instancespath}" ]; then
                        echo "WARNING: Found instances.txt in ${instancespath} with instances:"
                        echo ""
                        cat "${instancespath}"

                        while true; do
                                printf "Proceed with overwriting them? (THIS WILL DELETE THEM PERMANENTLY) (y/n, Default is n): " ; IFS= read -r choice

                                if [ "$choice" != 'y' ] && [ "$choice" != 'n' ] && [ "$choice" != '' ]; then
                                        continue
                                elif [ "$choice" = '' ]; then
                                        choice='n'
                                fi

                                break
                        done

                        if [ "$choice" = 'y' ]; then
                                echo "Deleting instances.txt at ${instancespath} and creating an empty one"
                                rm "${instancespath}"
                                touch "$instancespath"

                                for value in "${!valid_modpacks[@]}"; do
                                        unset dirs["$value"]
                                        unset params["$value"]
                                        unset jars["$value"]
                                        unset valid_modpacks["$value"]
                                done
                        fi
                fi
        else
                echo "Creating folder serverconfigs at ${instancespath}"
                mkdir "$instancespath"
                instancespath+="instances.txt"
                echo "Creating file instances.txt at ${instancespath}"
                touch "$instancespath"

                for value in "${!valid_modpacks[@]}"; do
                        unset dirs["$value"]
                        unset params["$value"]
                        unset jars["$value"]
                        unset valid_modpacks["$value"]
                done
        fi
}

initms(){
        instancespath="/home/$(whoami)/Desktop/serverconfigs/"

        if ! [ -d "$instancespath" ]; then
                echo "Creating folder serverconfigs at ${instancespath}"
                mkdir "$instancespath"
        fi

        instancespath+="instances.txt"

        if ! [ -f "${instancespath}" ]; then
                echo "Creating file instances.txt at ${instancespath}"
                touch "$instancespath"
        fi

        local modpack
        declare -A instances

        echo ""
        echo "Started loading from instances in ${instancespath}..."
        echo ""

        while IFS= read -r line; do
                local config="${line%%=*}"
                local value="${line#*=}"

                case "$config" in
                        '[instance]')
                                echo "Loading from instance"
                                modpack=''
                                ;;

                        'name')
                                instances+=(["$value"]=1)
                                if [ -n "${valid_modpacks["$value"]}" ]; then
                                        echo "Instance ${value} is already loaded"

                                        IFS= read -r line
                                        IFS= read -r line
                                        IFS= read -r line

                                        continue
                                fi

                                echo "Loaded ${value} in valid_modpacks"
                                valid_modpacks+=(["$value"]=1)
                                modpack="$value"
                                ;;

                        'folder')
                                echo "Loaded ${value} for ${modpack} in dirs"
                                dirs+=(["$modpack"]="$value")
                                ;;

                        'params')
                                echo "Loaded ${value} for ${modpack} in params"
                                params+=(["$modpack"]="$value")
                                ;;

                        'jar')
                                echo "Loaded ${value} for ${modpack} in jars"
                                echo ""
                                jars+=(["$modpack"]="$value")
                                modpack=''
                                ;;
                esac
        done < "$instancespath"

        for value in "${!valid_modpacks[@]}"; do
                if ! [ -n "${instances["$value"]}" ]; then
                        if [ "$1" = "$value" ]; then
                                echo "Deleted instance ${value} from configs and unloaded from instances"
                        else
                                echo "Couldn't find instance ${value}, unloading from instances"
                        fi

                        unset valid_modpacks["$value"]
                        unset dirs["$value"]
                        unset params["$value"]
                        unset jars["$value"]
                fi
        done
}

initms

addms(){
        local name
        local folder
        local parameters
        local jar

        echo "Creating server instance..."
        while true; do
                printf "Name: " ; IFS= read -r name

                if [ "$name" = '' ]; then
                        echo "Name can't be empty"
                        continue
                fi

                if [ -n "${valid_modpacks["$name"]}" ]; then
                        echo "Modpack name already exists"
                        continue
                fi

                break
        done


        while true; do
                printf "Folder: " ; IFS= read -r folder

                if ! [ -d "$folder" ]; then
                        echo "Folder path doesn't exist"
                        continue
                fi

                break
        done

        printf "Parameters: " ; IFS= read -r parameters

        while true; do
                local jarpath

                printf "Jar: " ; IFS= read -r jar

                jarpath="$folder"

                if ! [ "$folder" == "*/" ]; then
                        jarpath+='/'
                fi

                jarpath+="$jar"

                if ! [ -f "$jarpath" ]; then
                        echo "Jar file doesn't exist in specified folder"
                        continue
                fi

                break
        done

cat << EOF >> "$instancespath"
[instance]
name=$name
folder=$folder
params=$parameters
jar=$jar

EOF

        initms
}

remms(){
        local modpack
        local check
        mpcheck check "$1"
        if [ "$check" -eq 1 ]; then
                modpack="$1"
        else
                return 0
        fi

        sed -zi "s/\[instance\]\nname=$modpack\nfolder=[^\n]*\nparams=[^\n]*\njar=[^\n]*\n\n//g" "$instancespath"

        initms "$modpack"
}

lms(){
        echo "Path for instances is ${instancespath}"
        echo ""

        for modpack in "${!valid_modpacks[@]}"; do
                echo "Name - ${modpack}"
                echo "Folder - ${dirs[$modpack]}"
                echo "Parameters - ${params[$modpack]}"
                echo "Jar - ${jars[$modpack]}"
                echo ""
        done
}

rms(){
        if [ "$1" = 'help' ]; then
                echo 'Minecraft Server Runner - Put everything in an environment loader (e.g. ~/.bashrc) and reload environment (e.g. 'source ~/.bashrc')'

                echo ""
                echo 'Commands'
                echo 'rms - Run minecraft server - 2 Arguments - Modpack ; q (Optional)'
                echo 'cmsc - Create/Reset minecraft servers config'
                echo 'initms - Load servers config into the environment'
                echo 'lms - List servers config'
                echo 'addms - Add server config - 1 Argument - Modpack'
                echo 'remms - Remove server config - 1 Argument - Modpack'
                echo 'st - Check server status'
                echo 'ss - Stop server'

                echo ""
                echo "run modpack with 'rms <name> (q)', 'q' is for optional quiet mode"
                echo "which doesn't hold up the terminal and the server can be stopped with 'ss' command"


                return 0
        fi

        local modpack
        local check
        mpcheck check "$1"
        if [ "$check" -eq 1 ]; then
                modpack="$1"
        else
                echo "Type 'help' after 'rms' for command list"
                return 0
        fi

        local prevdir="$(pwd)"

        cms="$modpack"
        local runcommand="java -Xms2G -Xmx6G ${params[$modpack]} -jar "${jars[$modpack]}" nogui"

        echo "Starting ${modpack} Server..."

        cd "${dirs[$modpack]}" || return 0

        if [ "$2" = 'q' ]; then
                nohup $runcommand >/dev/null 2>&1 </dev/null &
                jobs -p >mspid.txt
                mspid="$(cat mspid.txt)"
                rm 'mspid.txt'
        else
                $runcommand
        fi

        cd "$prevdir" || return 0
}

st(){
        if [ "$cms" != '' ]; then
                echo "Running ${cms} server."
        else
                echo "No server is running."
        fi
}

ss(){
        if [ "$mspid" != "" ]; then
                echo "Server ${cms} stopped."
                kill -9 "$mspid"
                wait "$mspid" 2>/dev/null
                unset mspid
                unset cms
        else
                echo "Error: No server is running."
        fi
}
