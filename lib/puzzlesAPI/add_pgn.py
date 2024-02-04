import pandas as pd
import requests
import time

# Function to fetch PGN data from Lichess API
def get_puzzle_pgn(puzzle_id):
    api_url = f'https://lichess.org/api/puzzle/{puzzle_id}'
    response = requests.get(api_url)
    
    if response.status_code == 200:
        puzzle_data = response.json()
        return puzzle_data.get('game', {}).get('pgn', '')
    elif response.status_code == 429:
        print(f'Received 429 status code. Waiting for a full minute...')
        time.sleep(60)  # Wait for a full minute before resuming
        return get_puzzle_pgn(puzzle_id)  # Retry the request after waiting
    else:
        print(f'Error: {response.status_code} - Unable to fetch PGN data for Puzzle ID: {puzzle_id}')
        return None

# Read CSV into a DataFrame
csv_file_path = 'assets/data/subset_final.csv'
df = pd.read_csv(csv_file_path)

# Add a new column for PGN data
df['PGN'] = ''

# Loop through each row, fetch PGN data, and update the DataFrame
for index, row in df.iterrows():
    puzzle_id = row['PuzzleId']  # Replace 'PuzzleId' with your actual column name
    pgn = get_puzzle_pgn(puzzle_id)
    df.at[index, 'PGN'] = pgn
    
    # Introduce a delay after every 100 iterations
    if (index + 1) % 100 == 0 and index > 0:
        print(f'Waiting 5 seconds after {index + 1} iterations...')
        time.sleep(5)

# Remove unnecessary columns
columns_to_remove = ['NbPlays', 'GameUrl']
df = df.drop(columns=columns_to_remove)

# Save the updated DataFrame back to CSV
df.to_csv('assets/data/subset_updated.csv', index=False)
