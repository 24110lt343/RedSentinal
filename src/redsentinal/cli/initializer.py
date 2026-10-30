"""
RedSentinal — premium terminal boot UI
----------------------------------------
Minimal, intentional boot sequence: 3D wordmark -> one status line -> module
load bar. Nothing else. Presentation-only: no scanning / exploit logic.
"""

import time
import platform
import shutil
import typer
# from src.redsentinal.cli.initializer import initialize
from rich.console import Console
from rich.align import Align
from rich.panel import Panel
from rich.text import Text
from rich.progress import Progress, SpinnerColumn, BarColumn, TextColumn
from rich import box

console = Console()

# app = typer.Typer(
#     name="redsentinal",
#     help="Agentic AI Powered Web Security Framework"
# )


# @app.callback(invoke_without_command=True)
# def main():
#     initialize()

#     # Start your main menu here
#     print("RedSentinal started successfully!")


# ---------------------------------------------------------------------------
# Palette
# ---------------------------------------------------------------------------
ACCENT = "#ff3b3b"
ACCENT_DIM = "#5a0e0e"
FG = "#e8e8e8"
MUTED = "#6b6b6b"
CYAN = "#39c5cf"

# ---------------------------------------------------------------------------
# "REDSEN" wordmark — real figlet-style glyphs, R|E|D|S|E|N at fixed column
# widths (8,8,8,8,8,10). Columns 0:24 are "RED", columns 24:50 are "SEN" —
# each half gets its own solid colour, no blending.
# ---------------------------------------------------------------------------
_LOGO_LINES = [
    "██████╗ ███████╗██████╗ ███████╗███████╗███╗   ██╗",
    "██╔══██╗██╔════╝██╔══██╗██╔════╝██╔════╝████╗  ██║",
    "██████╔╝█████╗  ██║  ██║███████╗█████╗  ██╔██╗ ██║",
    "██╔══██╗██╔══╝  ██║  ██║╚════██║██╔══╝  ██║╚██╗██║",
    "██║  ██║███████╗██████╔╝███████║███████╗██║ ╚████║",
    "╚═╝  ╚═╝╚══════╝╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═══╝",
]
_RED_END = 24  # columns [0:24] spell "RED"; [24:50] spell "SEN"

RED_COLOR = "#ff3b3b"
SEN_COLOR = "#2f8fff"


def term_width():
    return shutil.get_terminal_size(fallback=(100, 30)).columns


def _blend(hex_color, factor):
    """Darken hex_color toward black by factor (0 = unchanged, 1 = black)."""
    r = int(hex_color[1:3], 16) * (1 - factor)
    g = int(hex_color[3:5], 16) * (1 - factor)
    b = int(hex_color[5:7], 16) * (1 - factor)
    return f"#{int(r):02x}{int(g):02x}{int(b):02x}"


def show_header():
    """The entire identity of the tool in one block: the REDSEN wordmark —
    red/blue split, with a soft fading reflection beneath for a glossy,
    premium finish — framed, with one refined line underneath. Nothing
    else competes with it."""
    console.clear()

    banner = Text()
    for line in _LOGO_LINES:
        banner.append(line[:_RED_END], style=f"bold {RED_COLOR}")
        banner.append(line[_RED_END:], style=f"bold {SEN_COLOR}")
        banner.append("\n")

    # faded reflection: the bottom row mirrored twice, fading toward black
    for i, factor in enumerate((0.55, 0.8)):
        row = _LOGO_LINES[-1]
        red = _blend(RED_COLOR, factor)
        sen = _blend(SEN_COLOR, factor)
        banner.append(row[:_RED_END], style=f"bold {red}")
        banner.append(row[_RED_END:], style=f"bold {sen}")
        if i == 0:
            banner.append("\n")

    panel_width = min(len(_LOGO_LINES[0]) + 10, term_width() - 2)

    console.print()
    console.print(Align.center(Text("▰" * 34, style=RED_COLOR) + Text("▰" * 34, style=SEN_COLOR)))
    console.print(
        Align.center(
            Panel(
                Align.center(banner),
                box=box.DOUBLE_EDGE,
                border_style=ACCENT,
                width=panel_width,
                padding=(1, 2),
            )
        )
    )
    console.print(Align.center(Text("▰" * 34, style=RED_COLOR) + Text("▰" * 34, style=SEN_COLOR)))

    line = Text()
    line.append("T E R R O R L A B S ", style=f"bold {FG}")
    line.append("   ✦   ", style=ACCENT)
    line.append("v0.1.0", style=f"bold {CYAN}")
    line.append("   ✦   ", style=ACCENT)
    line.append("AGENTIC WEB SECURITY FRAMEWORK", style=MUTED)
    console.print()
    console.print(Align.center(line))
    console.print()




def initialize():
    show_header()


if __name__ == "__main__":
    initialize()