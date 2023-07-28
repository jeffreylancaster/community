"""
Applet: Every Icon
Summary: Every 32x32 B&W icon
Description: Based on John F. Simon Jr.'s "Every Icon", 1997.
Author: Jeffrey Lancaster
"""

load("math.star", "math")
load("random.star", "random")
load("cache.star", "cache")
load("render.star", "render")
load("schema.star", "schema")

PIXLET_W = 64
PIXLET_H = 32
ICON_W = 32
ICON_H = 32

def get_counter():
    i = cache.get("counter")
    if i == None:
        i = 0
    i = int(i) + 1
    cache.set("counter", str(i), ttl_seconds = 31557600) # one year in sec
    return i

# from: adapted from https://datagy.io/python-int-to-binary/
def int_to_binary(integer):
    binary_array = []
    while(integer > 0):
        digit = integer % 2
        binary_array.insert(0, digit)
        integer = integer // 2
    binary_array = binary_array[::-1]
    return binary_array

def main(config):
    # need to determine clock speed...?
    # does this fill up 15s?
    frames = 25000

    i = 0
    print(cache.get("counter"))
    frameArray = []
    while i < frames:
        counter = get_counter()

        # convert counter to binary, returns array in reverse order
        binaryCounter = int_to_binary(counter)

        # use binary to build array
        columnChildren = []
        rowChildren = []
        for j in range(0, len(binaryCounter)):
            # build the row
            pixelColor = "#000" if binaryCounter[j] == 1 else "#FFF"
            if (j % ICON_W == 0 and j > 0) or j == len(binaryCounter)-1:
                columnChildren.append(
                    render.Row(
                        children = rowChildren,
                    ),
                )
                rowChildren = []
            rowChildren.append(
                render.Box(width = 1, height = 1, color = pixelColor),
            )
        frameArray.append(render.Column(children = columnChildren))

        i += 1

    # display array
    leftPad = math.floor(PIXLET_W/4) if config.bool("show_title", False) == False else 0

    stackChildren = [
        # background
        render.Box(
            color = config.get("background", "#000"),
            width = PIXLET_W,
            height = PIXLET_H
        ),
        # icon's white background box
        render.Padding(
            child = render.Box(color="#FFF", width = ICON_W, height = ICON_H),
            pad = (leftPad, 0, 0, 0)
        ),
        # icon's black-and-white overlay animation
        render.Padding(
            child = render.Animation(
                children = frameArray
            ),
            pad = (leftPad, 0, 0, 0)
        )
    ]

    if config.bool("show_title", False) == True:
        stackChildren.extend([
            render.Padding(
                child = render.WrappedText(content="Every Icon", color="#FFF", font="tom-thumb"),
                pad = (math.floor(PIXLET_W/2)+4, 5, 0, 0)
            ),
            render.Padding(
                child = render.Text(content="1997", color="#FFF", font="tom-thumb"),
                pad = (math.floor(PIXLET_W/2)+4, 22, 0, 0)
            )
        ])

    return render.Root(
        child = render.Stack(
            children = stackChildren,
        ),
        delay = 0,
        show_full_animation = True,
    )

def get_schema():
    # icons from: https://fontawesome.com/
    return schema.Schema(
        version = "1",
        fields = [
            schema.Color(
                id = "background",
                name = "Background",
                desc = "",
                icon = "brush",
                default = "#202A44",
            ),
            schema.Toggle(
                id = "show_title",
                name = "Show Title",
                desc = "Original artist info",
                icon = "font",
                default = False,
            ),
        ],
    )
