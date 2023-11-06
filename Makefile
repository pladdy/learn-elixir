# TODO: can use 'mix' instead of 'make' for most of these.
clean:
	mix clean

compile:
	mix compile

format:
	mix format

# Starts server
iex:
	iex -S mix

run-client:
	nc -v 127.0.0.1 4040

# When testing, kill any iex session; with a session active port 4040 will be
# in use and cause {:error, :eaddrinuse} from socket
test:
	mix test