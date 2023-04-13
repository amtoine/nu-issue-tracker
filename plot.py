import json
import matplotlib.pyplot as plt
import sys

if __name__ == "__main__":
    repo = sys.argv[1]
    data = json.loads(sys.argv[2])

    dates = [value["date"] for value in data]
    issues = [value["issues"] for value in data]
    plt.plot(dates, issues, label=f"{repo}")

    plt.title("number of issues over time")
    plt.legend()
    plt.show()
