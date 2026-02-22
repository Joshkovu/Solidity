# Makefile for Solidity Lab (Polkadot Hub EVM Hackathon)

.PHONY: all build test pocs fork clean

all: build

build:
	forge build

test:
	forge test

pocs:
	forge test --match-path "test/pocs/*"

fork:
	FORK_URL=$$FORK_URL forge test --match-path "test/fork/*"

clean:
	forge clean
