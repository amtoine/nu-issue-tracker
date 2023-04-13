import json
import matplotlib.pyplot as plt
import sys

if __name__ == "__main__":
    repo = sys.argv[1]
    data = json.loads(sys.argv[2])
    date = sys.argv[3]

    dates = [value["when"] for value in data]
    issues = [value["issues"] for value in data]
    plt.plot(dates, issues, label=f"{repo}")

    plt.xlabel(f"time in days: 0 is the current date ({date})")
    plt.ylabel("number of issues in the tracker")
    plt.title("number of issues over time")
    plt.legend()
    plt.show()
