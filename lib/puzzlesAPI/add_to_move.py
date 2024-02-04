import pandas as pd

# Read the CSV file into a DataFrame
df = pd.read_csv('assets/data/subset_updated.csv')

# Add a new column 'toMove' based on the 'FEN' column
def extract_to_move(fen):
    to_move= fen.split()[-5][0]
    if to_move == 'b':
        return 'w'
    else:
        return 'b'
        

df['toMove'] = df['FEN'].apply(extract_to_move)

# Display the modified DataFrame
print(df)

# Save the DataFrame back to a new CSV file if needed
df.to_csv('assets/data/subset_updated_final.csv', index=False)
