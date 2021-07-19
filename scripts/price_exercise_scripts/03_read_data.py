from brownie import PriceExercise


def format_btcusd(btcusd):
    return btcusd / (10**8)


def main():
    price_exercise = PriceExercise[-1]
    print(f"Reading data from {price_exercise.address}")
    if price_exercise.price() == 0:
        print(
            "You may have to wait a minute and then call this again, unless on a local chain!"
        )
    print(f"Price feed: {format_btcusd(price_exercise.getLatestPrice())}")
    print(f"Stored price: {format_btcusd(price_exercise.price())}")
    print(f"Price feed greater than stored price? {price_exercise.priceFeedGreater()}")
