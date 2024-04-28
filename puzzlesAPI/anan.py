import pandas as pd

# Load the dataset
df = pd.read_csv('assets/large_data/lichess_db_puzzle.csv')


# Filter for puzzles within a certain rating range (e.g., 1500-2000)
rating2000_2500 = df[(df['Rating'] >= 2000) & (df['Rating'] <= 2500) & (df['Popularity']>=90)]
rating1500_2000 = df[(df['Rating'] >= 1500) & (df['Rating'] <= 2000) & (df['Popularity']>=90)]
rating1000_1500 = df[(df['Rating'] >= 1000) & (df['Rating'] <= 1500) & (df['Popularity']>=90)]

# Get more samples then you need
subset2000_2500= rating2000_2500.sample(n=50000)
subset1500_2000= rating1500_2000.sample(n=50000)
subset1000_1500= rating1000_1500.sample(n=50000)



subset_opening_expert =  subset2000_2500[ subset2000_2500['Themes'].str.contains('opening')]
subset_opening_intermediate =  subset1500_2000[ subset1500_2000['Themes'].str.contains('opening')]
subset_opening_beginner =  subset1000_1500[ subset1000_1500['Themes'].str.contains('opening')]

subset_middlegame_expert =  subset2000_2500[ subset2000_2500['Themes'].str.contains('middlegame')]
subset_middlegame_intermediate =  subset1500_2000[ subset1500_2000['Themes'].str.contains('middlegame')]
subset_middlegame_beginner =  subset1000_1500[ subset1000_1500['Themes'].str.contains('middlegame')]

subset_endgame_expert =  subset2000_2500[ subset2000_2500['Themes'].str.contains('endgame')]
subset_endgame_intermediate =  subset1500_2000[ subset1500_2000['Themes'].str.contains('endgame')]
subset_endgame_beginner =  subset1000_1500[ subset1000_1500['Themes'].str.contains('endgame')]


subset_opening = pd.concat([
    subset_opening_expert.sample(n=1666),
    subset_opening_intermediate.sample(n=1666),
    subset_opening_beginner.sample(n=1666)
    
])
subset_middlegame = pd.concat([
    subset_middlegame_expert.sample(n=1666),
    subset_middlegame_intermediate.sample(n=1666),
    subset_middlegame_beginner.sample(n=1666)
    
])
subset_endgame = pd.concat([
    subset_endgame_expert.sample(n=1666),
    subset_endgame_intermediate.sample(n=1666),
    subset_endgame_beginner.sample(n=1666)
    
])


subset_final = pd.concat([
    subset_opening,
    subset_middlegame,
    subset_endgame
])



#subset.to_csv('assets/data/subset_300.csv',index=False)
subset_final.to_csv('assets/data/subset_final.csv',index=False)



