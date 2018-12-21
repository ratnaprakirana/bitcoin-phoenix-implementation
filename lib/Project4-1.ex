        defmodule Bitcoin.Project4 do
            use Phoenix.Channel
            #  Main Function from where the execution starts without the argument
            def main([]) do
                Bitcoin.Project4.process()
            end

            #  Main Function from where the execution starts with the argument
            # def main(args) do
            #     Bitcoin.Project4.process(args)
            # end
            #  Starts a process and calls the miner function without the argument
            # stores the number of the bitcoin created
            def process(socket) do
            #    push socket, "start_mining", %{"bitcoined" => "printing of some bitcoins"}
                count = 1
                {:ok, pid} = Task.Supervisor.start_link()

                # randomized the total number of bitcoin to be created
                total= Enum.random(40..60)

                # spawning a process for mining bitcoins
                server_id=spawn_link(fn() -> coin_print(4,count,pid,total,socket) end)
                :global.register_name(:serve,server_id)

                # distributing the processes among logical processors for fast mining
                logproc = 2*System.schedulers_online()
                for _ <- 1..logproc do
                    Task.Supervisor.async(pid,fn() -> miner(server_id,4) end)
                end
                receive do: (_ -> :ok)
            end

            #    Starts a process and calls the miner function with the argument
            # def process(parameter) do
            #     # stores the number of the bitcoin created
            #     count = 1
            #     {:ok, pid} = Task.Supervisor.start_link()
            #     k = String.to_integer(hd(parameter))
            #     # randomized the total number of bitcoin to be created
            #     total= Enum.random(200..1000)
            #
            #     # spawning a process for mining bitcoins according the trailing zeroes given by the user
            #     server_id=spawn_link(fn() -> coin_print(k,count,pid,total) end)
            #     :global.register_name(:serve,server_id)
            #
            #     # distributing the processes among logical processors for fast mining
            #     logproc = 2*System.schedulers_online()
            #     for _ <- 1..logproc do
            #         Task.Supervisor.async(pid,fn() -> miner(server_id,k) end)
            #     end
            #     receive do: (_ -> :ok)
            # end

            # Keeps adding bitcoins to the wallet
            def coin_print(k,count,pid,total,socket) do
                receive do
                    msg ->
                    IO.puts "#{count} #{msg}"
                    push socket, "start_mining", %{"bitcoined" => "#{msg}"}
                end

            # checking if the number of coins mined reached the required total of the bitcoins requested
                if count<=total do
                    coin_print(k,count+1,pid,total,socket)
                else
                    wallet_block(count,pid,socket)
                #        Process.exit(pid,:kill)
                end
            end

            # mines bitcoins with hash_id containing 3 trailing zeroes
            def miner(s_id,k) do
                msgt = "coin_master" <> randomizer(9)
                temp = :crypto.hash(:sha256, msgt) |> Base.encode16 |> String.downcase

                # if 3 trailing zeroes formed in the hash , send it to wallet
                if(String.slice(temp,0,k) === String.duplicate("0",k)) do
                    send(s_id, msgt <> "\t\t" <> temp)
                end
                miner(s_id,k)
            end

            # for creating random strings
            def randomizer(l) do
                :crypto.strong_rand_bytes(l) |> Base.url_encode64 |> binary_part(0, l) |> String.downcase
            end

            def miner (msgt) do
                :crypto.hash(:sha256, msgt) |> Base.encode16 |> String.downcase
            end

            #  Prints the wallet details in the file(amount, public key, private key) of all participants
            def wallet_block(count,pid,socket) do
            #    IO.puts"\n ********** Bitcoin mining complete **********\n"
                push socket, "start_mining", %{"bitcoined" => "\n ********** Bitcoin mining complete **********\n"}
                #IO.puts "Total bitcoins = #{count}"
            #    File.open!("transaction_invoice/participant_list.csv",[:write,:utf8])
            #    File.write("transaction_invoice/participant_list.csv","public key , balance in wallet \n",[:append,:utf8])
                list = [["amount","public key","private key"]]
                k=0
                participant = Enum.random(100..120)
                IO.puts ("Total participants = #{participant}")
                push socket, "wallet_det", %{"bitcoined" => "Total participants = #{participant}"}
                count1 = count*800
                total = count1
                list = wallet_chain(count1 ,list,k, total,participant,socket)
                push socket, "mining_list", %{"bitcoined" => list}
                #IO.inspect(list)
                    Process.sleep(12000)
                transaction(list,participant,socket)

                Process.exit(pid,:kill)
            end

            # Creates wallet for each participant with their own private and public key
            def wallet_chain(count,list,k , total , participant,socket) do
                # total number of participants with their wallets created
                if k==participant-1 do
                    count =if count<0 do
                        0
                    else
                        count
                    end
                    # generating a random public key of a participant
                    p = randomizer(9)

                    # generating a random 3 characters private key of a participant
                    q = randomizer(3)

                    t={count,p,q}
            #        File.write("transaction_invoice/participant_list.csv"," #{p},#{count} \n",[:append,:utf8])
                    t=Tuple.to_list(t)

                    #appending created wallet of each participant
                    list =list ++ [t]
            #        File.open!("transaction_invoice/details_#{p}_#{q}.txt",[:write,:utf8])
            #        File.write("transaction_invoice/details_#{p}_#{q}.txt","Details of the participant\n     balance in wallet = #{count}\n  public key = #{p}\n     private key = #{q}\n\n\n",[:append,:utf8])
                    push socket, "wallet_det", %{"bitcoined" => "Details of the participant --- #{p}\n     balance in wallet = #{count}\n\n"}
                    list
                else
                    len = trunc(:math.floor(total/(participant-3)))
                    len1 = trunc(:math.floor(total/(participant+3)))

                    # generating balance in the wallet for each participant
                    a=Enum.random(len1..len)

                    # generating a random public key of a participant
                    p = randomizer(9)

                    # generating a random 3 characters private key of a participant
                    q = randomizer(3)
                    t={a,p,q}
            #        File.write("transaction_invoice/participant_list.csv","#{p},#{a} \n",[:append,:utf8])
                    t=Tuple.to_list(t)

                    #appending created wallet of each participant
                    list =list ++ [t]
            #        File.open!("transaction_invoice/details_#{p}_#{q}.txt",[:write,:utf8])
            #        File.write("transaction_invoice/details_#{p}_#{q}.txt","Details of the participant\n    balance in wallet = #{a}\n    public key = #{p}\n    private key = #{q}\n\n\n",[:append,:utf8])
                    push socket, "wallet_det", %{"bitcoined" => "Details of the participant --- #{p}\n     balance in wallet = #{a}\n\n"}
                    # calling createwallet function until all the wallets of each participant has been created
                    Process.sleep(60)
                    wallet_chain(count - a,list,k+1,total,participant,socket)
                end
            end

            # Randomly selects number of participants that will be involved in the transactions
        	# Creates a file "transaction_invoice.txt" which will store all the transactions taking place between all the participants
            def transaction(list , participant,socket) do
                t=Enum.random(25..30)
                IO.puts ("Number of transactions to be performed = #{t}\n")
                push socket, "start_trans", %{"bitcoined" => "Number of transactions to be performed = #{t}\n"}
                IO.puts ("********** Wallet created **********\n")
            #    File.open!("transaction_invoice/transactions_invoice.csv",[:write,:utf8])
            #    File.write("transaction_invoice/transactions_invoice.csv","transaction id, debit account, credit account, amount transferred , status , time stamp\n",[:append,:utf8])
            push socket, "start_trans", %{"bitcoined" => "transaction id, debit account, credit account, amount transferred , status , time stamp\n"}
                invoice =[["transaction id","debit account" ,"credit account","amount","status"]]
                q=1
                transactionlist(list , participant ,t ,q,invoice,socket)
                IO.puts "\n********** All Transactions Completed ***********"
                push socket, "start_trans", %{"bitcoined" => "\n********** All Transactions Completed ***********"}
        #        IO.puts "\n\n********** NOTE:  For Transaction details - Go to transaction_invoice folder in the root directory **********"
            end

            # Checks whether a transaction is valid or not. If valid, stores that transaction in a list along with the transactionID.
            # Generates a complete transaction invoice for all participants
            def transactionlist(list , participant ,t , q , invoice,socket) do
                # check if the number of transactions to be performed has reached its maximum
                if (t > 0) do
                    a= Enum.random(1..participant)
                    b= Enum.random(1..participant)

                    # if same participant is involved in the transaction on both the credit and debit account, skip and create new transaction
                    if(a==b)do
                        transactionlist(list , participant ,t, q ,invoice,socket)

                    else
                        person1=Enum.at(list,a)
                        person2=Enum.at(list,b)
                        # gets balance of the participant from which amount has to be debited
                        amount1=Enum.at(person1,0)

                        private_key1=Enum.at(person1,2)
                        # gets the public key so that transaction can be performed
                        public_key1=Enum.at(person1,1)

                        private_key2=Enum.at(person2,2)
                        # gets the public key so that transaction can be performed
                        public_key2=Enum.at(person2,1)

                        # checks if the public keys to be used are present in the public keys list
                        val = key_validate(public_key1 ,public_key2, list)
                        if val do
                            maxamount1=trunc(:math.ceil(1.3*amount1))
                            minamount1=trunc(:math.floor(0.2*amount1))

                            # gets balance of the participant in which amount has to be credited
                            amount2=Enum.at(person2,0)

                            # randomly generates an amount for the transaction
                            amount = Enum.random(minamount1..maxamount1)

                            # generating transaction id for the transaction
                            transactionid = randomizer(12)

                            # storing every transaction in the public list called transactions_invoice

            #                File.write("transaction_invoice/transactions_invoice.csv","#{transactionid}  , #{Enum.at(person1,1)}    ,   #{Enum.at(person2,1)}   ,  #{amount}      ",[:append,:utf8])
                            #push socket, "start_mining", %{"bitcoined" => "#{transactionid}  , #{Enum.at(person1,1)}    ,   #{Enum.at(person2,1)}   ,  #{amount}    "}
                            translist = {transactionid, public_key1, public_key2, amount}
                            # generating time stamp for each transaction
                            time = NaiveDateTime.utc_now

                            Process.sleep(300)
                            # performing transaction if the amount to be transferred is less than the wallet amount of the participant
                            if (amount <= amount1) do
                                # updating wallet balance of each participant
                                person1 = List.replace_at(person1, 0, amount1 - amount)
                                person2 = List.replace_at(person2, 0, amount2 + amount)

                                # updating public list of transactions for each transaction performed if it is a success
                                push socket, "start_trans", %{"bitcoined" => "#{transactionid}  , #{Enum.at(person1,1)}    ,   #{Enum.at(person2,1)}   ,  #{amount}  ,success , #{time}\n "}
            #                    File.write("transaction_invoice/transactions_invoice.csv",", success , #{time}\n",[:append,:utf8])

                                # updating transaction invoice for each participant in their wallet
            #                    File.write("transaction_invoice/details_#{public_key1}_#{private_key1}.txt","Transaction details involving this participant \n    transaction id = #{transactionid}\n    debit account = #{public_key1}\n    credit account = #{public_key2}\n    amount transferred = #{amount}\n    status = success\n    Timestamp = #{time}\n\n\n",[:append,:utf8])
            #                    File.write("transaction_invoice/details_#{public_key2}_#{private_key2}.txt","Transaction details involving this participant \n    transaction id = #{transactionid}\n    debit account = #{public_key1}\n    credit account = #{public_key2}\n    amount transferred = #{amount}\n    status = success\n    Timestamp = #{time}\n\n\n",[:append,:utf8])

                                list = List.replace_at(list, a, person1)
                                list = List.replace_at(list, b, person2)
                                translist = Tuple.append(translist,"success")
                                translist=Tuple.to_list(translist)

                                # updating public list of transactions for each transaction performed
                                invoice = invoice ++ [translist]

                                # updating balance after every transaction for each participant in their wallet
            #                    File.write("transaction_invoice/details_#{public_key1}_#{private_key1}.txt","Details of the participant\n    amount in wallet = #{amount1-amount}\n    public key = #{public_key1}\n    private key = #{private_key1}\n\n\n",[:append,:utf8])
            #                    File.write("transaction_invoice/details_#{public_key2}_#{private_key2}.txt","Details of the participant\n    amount in wallet = #{amount2+amount}\n    public key = #{public_key2}\n    private key = #{private_key2}\n\n\n",[:append,:utf8])
                                IO.puts "Transaction no.#{q} Completed\n"
                                push socket, "start_trans", %{"bitcoined" => "Transaction no.#{q} Completed\n"}
                                transactionlist(list,participant,t-1 , q+1 ,invoice,socket)
                            else
                                # updating public list of transactions for each transaction performed if it fails
            #                    File.write("transaction_invoice/transactions_invoice.csv",", failed , #{time}\n",[:append,:utf8])
                                push socket, "start_trans", %{"bitcoined" => "#{transactionid}  , #{Enum.at(person1,1)}    ,   #{Enum.at(person2,1)}   ,  #{amount}  ,failed , #{time}\n "}
                                # updating transaction invoice for each participant in their wallet
            #                    File.write("transaction_invoice/details_#{public_key1}_#{private_key1}.txt","Transaction details involving this participant \n    transaction id = #{transactionid}\n    debit account = #{public_key1}\n    credit account = #{public_key2}\n    amount transferred = #{amount}\n    status = failed\n    Timestamp = #{time}\n\n\n",[:append,:utf8])
            #                    File.write("transaction_invoice/details_#{public_key2}_#{private_key2}.txt","Transaction details involving this participant \n    transaction id = #{transactionid}\n    debit account = #{public_key1}\n    credit account = #{public_key2}\n    amount transferred = #{amount}\n    status = failed\n    Timestamp = #{time}\n\n\n",[:append,:utf8])

                                translist = Tuple.append(translist,"failed")
                                translist = Tuple.to_list(translist)

                                # updating public list of transactions for each transaction performed
                                invoice = invoice ++ [translist]

                                # updating balance after every transaction for each participant in their wallet
            #                    File.write("transaction_invoice/details_#{public_key1}_#{private_key1}.txt","Details of the participant\n    amount in wallet = #{amount1}\n    public key = #{public_key1}\n    private key = #{private_key1}\n\n\n",[:append,:utf8])
            #                    File.write("transaction_invoice/details_#{public_key2}_#{private_key2}.txt","Details of the participant\n    amount in wallet = #{amount2}\n    public key = #{public_key2}\n    private key = #{private_key2}\n\n\n",[:append,:utf8])

                                # calling transactionlist function until all the transactions has been performed
                                push socket, "start_trans", %{"bitcoined" => "Transaction no.#{q} Completed\n"}
                                IO.puts "Transaction no.#{q} Completed\n"
                                transactionlist(list,participant,t-1, q+1 ,invoice,socket)
                            end
                        else
                            IO.puts "Wrong public key"
                        end
                    end
                else
                    IO.puts "dvdf"
                    push socket, "trans", %{"bitcoined" => invoice}
                end
            end

            def transactionlist(list , amount) do
                person1 = Enum.at(list,0)
                person2 = Enum.at(list,1)
                amount1 = Enum.at(person1,0)
                amount2 = Enum.at(person2,0)
                person1 = List.replace_at(person1, 0, amount1 - amount)
                person2 = List.replace_at(person2, 0, amount2 + amount)
                list = List.replace_at(list, 0, person1)
                list = List.replace_at(list, 1, person2)
                list
            end

            # checks if the public keys to be used in the transactions are present in the public key list
            def key_validate(p1 , p2 , list) do
                list1 = List.flatten(list)
                val1 = Enum.member?(list1, p1)
                val2 = Enum.member?(list1, p2)
                IO.puts "keys validated"
                if (val1 and val2) do
                    true
                else
                    false
                end
            end
        end
