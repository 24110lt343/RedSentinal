import typer

from src.redsentinal.cli.initializer import initialize

app = typer.Typer(
    name="redsentinal",
    help="Agentic AI Powered Web Security Framework"
)


@app.callback(invoke_without_command=True)
def main():
    initialize()


if __name__ == "__main__":
    app()