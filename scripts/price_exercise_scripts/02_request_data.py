from brownie import PriceExercise, config, network
from scripts.helpful_scripts import fund_with_link, get_account


def main():
    account = get_account()
    price_exercise = PriceExercise[-1]
    tx = fund_with_link(
        price_exercise, amount=config["networks"][network.show_active()]["fee"]
    )
    tx.wait(1)

    request_tx = price_exercise.requestPriceData({"from": account})
    request_tx.wait(1)

    print("Request sent!")
