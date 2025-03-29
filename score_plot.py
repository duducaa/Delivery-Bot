import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df_main = pd.read_csv("./scores/main_score.csv", sep=";")
df_modified = pd.read_csv("./scores/modified_score.csv", sep=";")

unfinished_mod = df_modified[df_modified["unfinished"] == 1].index.to_list()
unfinished = df_main[df_main["unfinished"] == 1].index.to_list()
unfinished.extend(unfinished_mod)
unfinished = set(unfinished)

df_main = df_main.drop(index=unfinished).iloc[:, :-1]
df_modified = df_modified.drop(index=unfinished).iloc[:, :-1]

assert df_main["seed"].shape[0] == df_modified["seed"].shape[0]
assert (df_main["seed"] == df_modified["seed"]).sum() == df_main.shape[0]

plt.subplots(2, 1, sharex=True)
plt.figure(figsize=(20, 10))

def column_plot(column: str, ax):
    plt.title(f"{column.capitalize()} comparison")
    
    main = df_main.copy()
    mod = df_modified.copy()
    
    main["source"] = "main"
    main.rename(columns={column: "main"}, inplace=True)
    
    mod["source"] = "modified"
    mod.rename(columns={column: "modified"}, inplace=True)
    
    df = main.loc[:, ["main", "seed"]].join(mod.loc[:, ["modified", "seed"]], lsuffix="_main", rsuffix="_modified").drop(columns=["seed_modified"]).rename(columns={"seed_main": "seed"})
    
    df.plot.bar(x="seed", ax=ax)
    plt.xticks(rotation=90)
    
    return df

ax0 = plt.subplot(2, 1, 1)
df = column_plot("score", ax0)
print(sum(df["modified"] > df["main"]))
ax1 = plt.subplot(2, 1, 2)
column_plot("steps", ax1)

plt.tight_layout()
plt.savefig("./metrics.png")

