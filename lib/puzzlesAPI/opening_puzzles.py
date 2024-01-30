
# Replace this with the actual pgn_strings using the api https://lichess.org/api/puzzle/{puzzle_id}
pgn_string = "e4 c5 d4 cxd4 c3 Nf6 Nf3 Nxe4 cxd4 d5 Nc3 Nxc3 bxc3 Nc6 Ba3 Bg4 Be2 Qa5 Qb3 Rb8 Bb4 Nxb4 cxb4 Qb6 O-O e6"

moves = pgn_string.split()
# Get all moves up to the one before the last move
moves_up_to_before_last = moves[:-1]  # Exclude the last two elements
resulting_pgn = ' '.join(moves_up_to_before_last)
print(resulting_pgn)

# Update the local databsase with the added resulting_pgn

