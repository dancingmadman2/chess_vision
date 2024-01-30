import pandas as pd

# Load the dataset
df = pd.read_csv('assets/data/lichess_db_puzzle.csv')


# Filter for puzzles within a certain rating range (e.g., 1500-2000)
rating2000_2500 = df[(df['Rating'] >= 2000) & (df['Rating'] <= 2500) & (df['Popularity']>=95)]
rating1500_2000 = df[(df['Rating'] >= 1500) & (df['Rating'] <= 2000) & (df['Popularity']>=95)]
rating1000_1500 = df[(df['Rating'] >= 1000) & (df['Rating'] <= 1500) & (df['Popularity']>=95)]

subset2000_2500= rating2000_2500.sample(n=10000)
subset1500_2000= rating1500_2000.sample(n=10000)
subset1000_1500= rating1000_1500.sample(n=10000)
subset = pd.concat([
    rating2000_2500.sample(n=10000),
    rating1500_2000.sample(n=10000),
    rating1000_1500.sample(n=10000)
])


# Save the filtered puzzles to a new CSV file
subset2000_2500.to_csv('assets/data/rating2000_2500.csv', index=False)
subset1500_2000.to_csv('assets/data/rating1500_2000.csv', index=False)
subset1000_1500.to_csv('assets/data/rating1000_1500.csv', index=False)
subset.to_csv('assets/data/subset.csv',index=False)


#beginnerF=pd.read_csv('assets/data/rating2000_2500.csv')

