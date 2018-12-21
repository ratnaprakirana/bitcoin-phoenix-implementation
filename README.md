# bitcoin-phoenix-implementation
# Bitcoin Protocol Implementation

COP5615 - Distributed Operating Systems Principles Project 4.2

Youtube link to the video demo - https://youtu.be/NiDA_-RGIjA

The goal of this project is to implement Bitcoin Protocol simulation with at least 100 participants in which coins get mined and transacted. We have to also implement a web interface using the Phoenix that allows access to the ongoing simulation using a web browser.

## Authors

* **Ratna Prakirana ** - *UFID: 3663-9969*
* **Eesh Kant Joshi** - *UFID: 1010-1069*

## Execution

1) Run these commands in the console:

$ mix deps.get
$ cd assets
$ npm i
$ cd ..
$ mix phx.server

2) Open the web browser and type "http://localhost:4000" in the address bar.

3) Refresh the page.

4) Click the "Start_Mining" button for starting the mining and the transaction process.

5) The output is generated on the web page in real-time.

	
## Sample Output

The following output was generated on the web page along with the graphs.
```
coin_mastergim3jbxjm  000037d27b9fa836932c3d3e2eb70e2dfd5d99bd97f0a8cbea47ec9fffaeb6f6
coin_mastervoat61gwb  000fe2a02e61b0f23a3159eb8f6dc0585932ca2c2a74b9d44d0ee4177649e565
coin_master54h8c20bo  0009c604fdbca3817493dcc25f36704902bbd1ac6abc0c7f53ce25762ff4058e


 ********** Bitcoin mining complete **********

Total bitcoins = 821
Total participants = 5
Number of transactions to be performed = 7

********** Wallet created **********

keys validated
Transaction no.1 Completed

keys validated
Transaction no.2 Completed

keys validated
Transaction no.3 Completed

keys validated
Transaction no.4 Completed

keys validated
Transaction no.5 Completed

keys validated
Transaction no.6 Completed

keys validated
Transaction no.7 Completed


********** All Transactions Completed ***********
```

## Graphs ##

1) Bitcoin distribution per participant
This graph represents the number of bitcoins each participant has after all the transactions have been completed. On the x-axis is the public key of each participant and on the y-axis is the amount of bitcoins.

2) Bitcoin transacted per transaction
This graph represents the number of bitcoins involved in each transaction. On the x-axis is the transaction ID of each transaction and on the y-axis is the amount of bitcoins.
