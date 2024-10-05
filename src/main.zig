const std = @import("std");

const clear = "\x1b[J";
const home = "\x1b[H";

const Frame = struct {
    data: []const u8,
    names: []const []const u8,
    spookiness: u32,
};

const time_between_frames_ns = std.time.ns_per_s * 2;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    // Fetch top secret random seed
    const seed: u64 = @bitCast(std.time.timestamp());
    var rng = std.Random.DefaultPrng.init(seed);

    var frames = [_]Frame{
        .{
            .data = bats,
            .names = &.{ "bat", "bats" },
            .spookiness = 6,
        },
        .{
            .data = pumpkins,
            .names = &.{ "pumpkin", "pumpkins" },
            .spookiness = 2,
        },
        .{
            .data = spiders,
            .names = &.{ "spider", "spiders" },
            .spookiness = 4,
        },
        .{
            .data = witch,
            .names = &.{"witch"},
            .spookiness = 8,
        },
        .{
            .data = skeletons,
            .names = &.{ "skeleton", "skeletons" },
            .spookiness = 10,
        },
    };

    rng.random().shuffle(Frame, &frames);

    const answer_index = rng.random().int(usize) % frames.len;
    const selected_frame = &frames[answer_index];

    for (frames) |frame| {
        try stdout.writeAll(home);
        try stdout.writeAll(clear);
        try stdout.writeAll(frame.data);
        std.time.sleep(time_between_frames_ns);
    }

    try stdout.writeAll(home);
    try stdout.writeAll(clear);

    try stdout.print("what was image number {d}? (one word)> ", .{answer_index + 1});

    var name_buffer: [256]u8 = undefined;
    const name_size = try stdin.read(&name_buffer);
    const input_name = std.mem.trim(u8, name_buffer[0..name_size], &std.ascii.whitespace);

    var spookiness_buffer: [256]u8 = undefined;
    const spookiness = while (true) {
        try stdout.writeAll("how spooky was it? (1-10)> ");

        const spookiness_size = try stdin.read(&spookiness_buffer);
        const spookiness_str = std.mem.trim(u8, spookiness_buffer[0..spookiness_size], &std.ascii.whitespace);

        break std.fmt.parseInt(u32, spookiness_str, 10) catch {
            try stdout.writeAll("enter a number!\n");
            continue;
        };
    };

    var names_match = false;
    for (selected_frame.names) |name| {
        if (std.ascii.eqlIgnoreCase(input_name, name)) {
            names_match = true;
            break;
        }
    }

    // accurate spookiness scale for a human
    var spookiness_match = false;
    const spookiness_margin = 1;
    if (spookiness >= selected_frame.spookiness - spookiness_margin and
        spookiness <= selected_frame.spookiness + spookiness_margin)
    {
        spookiness_match = true;
    }

    if (names_match and spookiness_match) {
        try stdout.writeAll("you are human\n");
        try stdout.writeAll(happy_halloween);
    } else {
        try stdout.writeAll("robot detected!\n");
        try stdout.writeAll(robot);
    }
}

// ASCII art by Joan Stark
const bats =
    \\        =/\                 /\=
    \\         / \'._   (\_/)   _.'/ \       (_                   _)
    \\        / .''._'--(o.o)--'_.''. \       /\                 /\
    \\       /.' _/ |`'=/ " \='`| \_ `.\     / \'._   (\_/)   _.'/ \
    \\      /` .' `\;-,'\___/',-;/` '. '\   /_.''._'--('.')--'_.''._\
    \\     /.-'       `\(-V-)/`       `-.\  | \_ / `;=/ " \=;` \ _/ |
    \\                  "   "               \/  `\__|`\___/`|__/`  \/
    \\                   (,_    ,_,    _,)   `       \(/|\)/       `
    \\                   /|\`-._( )_.-'/|\            " ` "
    \\                  / | \`'-/ \-'`/ | \         _   ,_,   _
    \\                 /  |_.'-.\ /.-'._|  \       / `'=) (='` \
    \\                /_.-'      "      `-._\     /.-.-.\ /.-.-.\
    \\        /\                 /\               `      "      `
    \\       / \'._   (\_/)   _.'/ \            =/\                 /\=
    \\      /_.''._'--('.')--'_.''._\           / \'._   (\_/)   _.'/ \
    \\      | \_ / `;=/ " \=;` \ _/ |          / .''._'--(e.e)--'_.''. \
    \\       \/ `\__|`\___/`|__/` \/          /.' _/ |`'=/ " \='`| \_ `.\
    \\        `      \(/|\)/      `          /` .' `\;-,'\___/',-;/` '. '\
    \\                " ` "                 /.-'       `\(/V\)/`       `-.\
    \\                                      `            "   "            `
;

// ASCII art by Joan Stark
const pumpkins =
    \\                                            _
    \\                              /\              )\
    \\                _           __)_)__        .'`--`'.
    \\                )\_      .-'._'-'_.'-.    /  ^  ^  \
    \\             .'`---`'. .'.' /o\'/o\ '.'.  \ \/\/\/ /
    \\            /  <> <>  \ : ._:  0  :_. : \  '------'       _J_
    \\            |    A    |:   \\/\_/\//   : |     _/)_    .'`---`'.
    \\            \  <\_/>  / :  :\/\_/\/:  : /   .'`----`'./.'0\ 0\  \
    \\           _?_._`"`_.'`'-:__:__:__:__:-'   /.'<\   /> \:   o    |
    \\        .'`---`'.``  _/(              /\   |:,___A___,|' V===V  /
    \\       /.'a . a  \.'`---`'.        __(_(__ \' \_____/ /'._____.'
    \\       |:  ___   /.'/\ /\  \    .-'._'-'_.'-:.______.' _?_
    \\       \'  \_/   |:   ^    |  .'.' (o\'/o) '.'.     .'`"""`'.
    \\        '._____.'\' 'vvv'  / / :_/_:  A  :_\_: \   /   ^.^   \
    \\                  '.__.__.' | :   \'=...='/   : |  \  `===`  /
    \\                             \ :  :'.___.':  : /    `-------`
    \\                              '-:__:__:__:__:-'
;

// ASCII art by Joan Stark
const spiders =
    \\                                       _
    \\           /      \         __      _\( )/_
    \\        \  \  ,,  /  /   | /  \ |    /(O)\
    \\         '-.`\()/`.-'   \_\\  //_/    _.._   _\(o)/_  //  \\
    \\        .--_'(  )'_--.   .'/()\'.   .'    '.  /(_)\  _\\()//_
    \\       / /` /`""`\ `\ \   \\  //   /   __   \       / //  \\ \
    \\        |  |  ><  |  |          ,  |   ><   |  ,     | \__/ |
    \\        \  \      /  /         . \  \      /  / .              _
    \\       _    '.__.'    _\(O)/_   \_'--`(  )'--'_/     __     _\(_)/_
    \\    _\( )/_            /(_)\      .--'/()\'--.    | /  \ |   /(O)\
    \\     /(O)\  //  \\         _     /  /` '' `\  \  \_\\  //_/
    \\           _\\()//_     _\(_)/_    |        |      //()\\
    \\          / //  \\ \     /(o)\      \      /       \\  //
    \\           | \__/ |
;

// ASCII art by Joan Stark
const happy_halloween =
    \\           __   __
    \\          |  |_|  |______ _,___ _,___ _   _         \--/
    \\          |   _   |__    |  __ |  __ | |_| |     /`-'  '-`\
    \\          |__| |__|__-_,_| ,___| ,___|___, |    /          \
    \\                         |_|   |_|       |_|   /.'|/\  /\|'.\
    \\        __   __        _ _                           \/
    \\       |  |_|  |______| | |______ __ _ __ ______ ______ _,____
    \\       |   _   |__    | | |  __  |  | |  |  --__|  --__|  __  \
    \\       |__| |__|__-_,_|_|_|______|_______|______|______|_|  |_|
;

// ASCII art by Joan Stark
const witch =
    \\     ___
    \\   .'   `"-._
    \\  / ,        `'-_.-.
    \\ / /`'.       ,' _  |
    \\`-'    `-.  ,' ,'\\/
    \\          \, ,'  ee`-.
    \\          / ./  ,(_   \      ,
    \\         (_/\\\ \__|`--'     ||
    \\         ///\\|     \        ||
    \\         ////||-./`-.}    .--||
    \\            /     `-.__.-`_.-.|
    \\            |      '._,-'`|___}    `;
    \\            /   '.        |/ || ,;'`
    \\            |     '.__,.-`   || ':,
    \\            |       |        || ,;'
    \\            /       /     _,.||oOoO.,_
    \\           |        |     \-.O,o_O..-/
    \\          /         /     /          \
    \\         |         /     /            \
    \\         |         |    |      ,       |
    \\         /         |    \   ) (     )  /
    \\        |           \   ,'.(:, ),: (_.'.
    \\       /            /'.' ="`""="="=="= '.
    \\      `'"---'-.__.'"""`    ` "" "" `""
;

// ASCII art by Joan Stark
const skeletons =
    \\                                           .-. _)/
    \\                                          (0,0) .\
    \\                                           (u)   ()
    \\      .-.                           _\)  .-="=-.//
    \\     (o,o)                            \,//==\===
    \\      (e)                              ()  =====            .-.
    \\    .-="=-.  \(_           .-.         _____ =,=           (a.a)
    \\   //==I==\\,/            (d.b)       ()--___(0V0)  (/_     (=)
    \\  ()  ="=  ()              (u)        ||()----'      \, ___.="==-._
    \\   \`(0V0)               .-="-.       |' \\           ()---` ==\==\\
    \\  /|) ||\\              //==/=\\    =="   \'                   ="= ()
    \\      || \\  ==.       () ==== ()_/_    =="               ____(0V0) \`
    \\      ()  ()    \,      `\"=      `                      ()---` // (|\
    \\     //  //      \\ ___(0);`               \)/ .-.       ||    //
    \\    '/  '/        ()---'  \\                /,(o,o)      |'   ()
    \\    "== "==                \\              ()  (w)     =="     \\
    \\                            ()      /_ ___  \\,=",              \`
    \\                           //       '-()-()   =/=\\            =="
    \\                          '/         //\\||  ==== ()
    \\                          "==       /`  \\|  ="=  `|
    \\                                  =="    `(0V0)    '--
;

// ASCII art by christopher
const robot =
    \\                   _____
    \\                  |     |
    \\                  | | | |
    \\                  |_____|
    \\            ____ ___|_|___ ____
    \\           ()___)         ()___)
    \\           // /|           |\ \\
    \\          // / |           | \ \\
    \\         (___) |___________| (___)
    \\         (___)   (_______)   (___)
    \\         (___)     (___)     (___)
    \\         (___)      |_|      (___)
    \\         (___)  ___/___\___   | |
    \\          | |  |           |  | |
    \\          | |  |___________| /___\
    \\         /___\  |||     ||| //   \\
    \\        //   \\ |||     ||| \\   //
    \\        \\   // |||     |||  \\ //
    \\         \\ // ()__)   (__()
    \\               ///       \\\
    \\              ///         \\\
    \\            _///___     ___\\\_
    \\           |_______|   |_______|
;
