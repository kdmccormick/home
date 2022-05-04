#!/usr/bin/env python3

# Load online banking -> account details -> desired range.
# In network debugger, filter for onlinebanking.tdbank.com/ngp_api and reload page.
# Copy response payload contents, pipe to this script, copy output.
# Repeat for all API calls as necessary.

import sys
import json


def normalize_description(rt):
    if "description2" in rt:
        if rt["description1"] == "VISA DDA PUR":
            descrip = rt["description2"]
        else:
            descrip = rt["description1"] + " ; " + rt["description2"]
    else:
        descrip = rt["description1"]
    words = [word for word in descrip.split(" ") if word]
    if len(words[0]) == 6 and all(c.isdigit() for c in words[0]):
        words = words[1:]
    return " ".join(words)


def get_transaction_triples(raw_transactions):
    for rt in raw_transactions:
        if rt["paymentType"] == "CREDIT":
            continue
        if rt["paymentType"] != "DEBIT":
            raise ValueError(f"unknown payment type {rt['paymentType']}")
        t_date = rt["transactionDate"]
        t_dollars = round(rt["amount"]["dollarAmount"])
        t_description = normalize_description(rt)
        yield (t_date, t_description, t_dollars)


def main():
    raw_data = json.load(sys.stdin)
    raw_transactions = raw_data["accountTransactions"]["transactions"]
    for t in sorted(get_transaction_triples(raw_transactions)):
        print(*t, sep="\t")
    return 0


if __name__ == "__main__":
    sys.exit(main())
