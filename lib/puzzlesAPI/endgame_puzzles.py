import pandas as pd

# Load the dataset
bf = pd.read_csv('assets/data/rating1000_1500.csv') # beginner
af = pd.read_csv('assets/data/rating1500_2000.csv') # average
ef = pd.read_csv('assets/data/rating2000_2500.csv') # expert

# Filter for puzzles within a certain rating range (e.g., 1500-2000)
endgames_rating2000_2500 = ef[ ef['Themes'].str.contains('endgame')]
endgames_rating1500_2000 =af[ af['Themes'].str.contains('endgame')]
endgames_rating1000_1500 =bf[ bf['Themes'].str.contains('endgame')]

# Save the csv file
endgames_rating2000_2500.to_csv('assets/data/endgames_rating2000_2500.csv', index=False)
endgames_rating1500_2000.to_csv('assets/data/endgames_rating1500_2000.csv', index=False)
endgames_rating1000_1500.to_csv('assets/data/endgames_rating1000_1500.csv', index=False)