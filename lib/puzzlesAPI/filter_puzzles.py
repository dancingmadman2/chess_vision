import pandas as pd

# Load the dataset
df = pd.read_csv('assets/large_data/lichess_db_puzzle.csv')

# Function to process subsets
def process_subsets(df, themes, ratings, sample_sizes, n_samples_each):
    subsets = []
    for theme, rating, sample_size in zip(themes, ratings, sample_sizes):
        subset = df[(df['Rating'].between(rating[0], rating[1])) & (df['Popularity'] >= 90) & (df['Themes'].str.contains(theme))]
        subset_sample = subset.sample(min(sample_size, len(subset)), random_state=42)  # Safeguard with min to avoid errors
        subsets.append(subset_sample.sample(n=n_samples_each, random_state=42))
    return pd.concat(subsets)

# Define themes and ratings
themes = ['opening', 'middlegame', 'endgame']
ratings = [(2000, 2500), (1500, 2000), (1000, 1500)]
sample_sizes = [5000, 5000, 5000]  # Adjust initial sampling if possible
n_samples_each = 1666

# Processing each theme
final_subsets = [process_subsets(df, [theme]*3, ratings, sample_sizes, n_samples_each) for theme in themes]

# Concatenate all final subsets
subset_final = pd.concat(final_subsets)
subset_final.to_csv('assets/data/subset_final.csv', index=False)
