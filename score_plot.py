import pandas as pd
import matplotlib.pyplot as plt

df_main = pd.read_csv("./scores/main_score.csv", sep=";")
df_modified = pd.read_csv("./scores/modified_score.csv", sep=";")

df_main = df_main[df_main["unfinished"] != 1].iloc[:, :-1]
df_modified = df_modified[df_modified["unfinished"] != 1].iloc[:, :-1]

plt.subplots(2, 1)

def column_plot(column: str):
    plt.title(f"{column.capitalize()} comparison")
    plt.plot( df_main[column])
    plt.plot(df_modified[column])
    plt.legend(["main", "modified"])

plt.subplot(2, 1, 1)
column_plot("score")
plt.subplot(2, 1, 2)
column_plot("steps")

plt.tight_layout()
plt.savefig("./metrics.png")