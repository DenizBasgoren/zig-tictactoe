const std = @import("std");

const Color = enum(u8) {
    red, green, yellow, blue
};

const Cell = enum {
    empty, x, o,

    fn print(this: Cell) void {
        return switch(this) {
            .empty => {
                printz(" ");
            },
            .x => {
                printColored("X", Color.red);
            },
            .o => {
                printColored("O", Color.green);
            }
        };
    }
};

const Game = enum {
    continues, xWon, oWon, tie
};

var game = Game.continues;

const PrintedError = enum {
    none, full, oob, wut
};

var printedError = PrintedError.none;

var lastInput: u8 = undefined;

var board = [_]Cell{ Cell.empty } ** 9;


fn printz(comptime str: []const u8) void {
    std.debug.print(str, .{});
}

fn printColored(comptime str: []const u8, color: Color ) void {
    std.debug.print("\x1b[{}m" ++ str ++ "\x1b[39m", .{@enumToInt(color)+31});
}

fn clearScreen() void {
    printz("\x1b[2J"++"\x1b[3J"++"\x1b[1;1H");
}


pub fn main() void {
    
    while(true) {
        clearScreen();
        printGame();
        takeInput();
        updateGame();
    }

}

fn printGame() void {
    printColored("TicTacToe in Zig by DenizBasgoren\n\n", Color.yellow);

    const horizontalBorders = "   -   -   -\n";
    const verticalBorders1 = " | ";
    const verticalBorders2 = " |\n";

    var row: u8 = 0;
    while(row < 3) : (row+=1) {
        printz(horizontalBorders);

        var col: u8 = 0;
        while(col < 3) : (col+=1) {
            printz(verticalBorders1);
            board[row*3 + col].print();
        }

        printz(verticalBorders2);
    }
    
    printz(horizontalBorders ++ "\n");

    switch( printedError ) {
        .none => {
            printz("\n");
        },
        .oob => {
            printz("No such cell. Cells are numbered 1-9.\n");
        },
        .full => {
            std.debug.print("Cannot put X on cell {} because this cell is full.\n", .{lastInput-'1'});
        },
        .wut => {
            printz("Wut?\n");
        }
    }

    // remove after printing once
    printedError = PrintedError.none;

    switch(game) {
        .continues => {
            printz("Enter the number of cell (1-9) to put X on: ");
        },
        .xWon => {
            printz("You won! Restart? (y/n) ");
        },
        .oWon => {
            printz("You failed! Restart? (y/n) ");
        },
        .tie => {
            printz("Tie! Restart? (y/n) ");
        },
    }

}

fn takeInput() void {
    lastInput = std.io.getStdIn().reader().readByte() catch {
        std.process.exit(1);
    };

    std.io.getStdIn().reader().skipUntilDelimiterOrEof(10) catch {
        std.process.exit(2);
    };
}

fn updateGame() void {
    
    switch(game) {
    .xWon, .oWon, .tie => {
        switch(lastInput) {
        'y', 'Y' => {
            // remove all cells
            board = [_]Cell{ Cell.empty } ** 9;

            // make game 'continue' again
            game = Game.continues;
            return;
        },
        'n', 'N' => {
            printz("Bye ^.^\n");
            std.process.exit(0);
            // return; // unreachable?
        },
        else => {
            printedError = .wut; // can i do this?
            return;
        }}
        return;
    },

    .continues => {
        switch(lastInput) {
        '1','2','3','4','5','6','7','8','9' => {
            if (board[lastInput-'1'] != Cell.empty) {
                printedError = .full;
                return;
            }
            else {
                board[lastInput-'1'] = Cell.x;
                // break out of 2 switches
            }
        },
        else => {
            printedError = .oob;
            return;
        }}
    }}

    // check if x (you) won
    if ( didPlayerWin(Cell.x) ) {
        // if won, change gamestate to won
        game = Game.xWon;
        return;
    }

    // play as o (cpu)
    cpuMove();

    // check if o (cpu) won

    if ( didPlayerWin(Cell.o) ) {
        game = Game.oWon;
        return;
    }
}


fn didPlayerWin( player: Cell ) bool {
    if ( board[0]==player and board[1]==player and board[2]==player or
        board[3]==player and board[4]==player and board[5]==player or
        board[6]==player and board[7]==player and board[8]==player or
        board[0]==player and board[3]==player and board[6]==player or
        board[1]==player and board[4]==player and board[7]==player or
        board[2]==player and board[5]==player and board[8]==player or
        board[0]==player and board[4]==player and board[8]==player or
        board[2]==player and board[4]==player and board[6]==player
    ) {
        return true;
    }
    return false;
}


fn cpuMove() void {
    const cpu = Cell.o;
    const hooman = Cell.x;
    const empty = Cell.empty;

    // if cpu is about to win (two 'O', one empty), win
    if (        board[0]==empty and board[1]==cpu and board[2]==cpu or
                board[0]==empty and board[4]==cpu and board[8]==cpu or
                board[0]==empty and board[3]==cpu and board[6]==cpu
    ) { board[0] = cpu; }
    else if (   board[2]==empty and board[1]==cpu and board[0]==cpu or
                board[2]==empty and board[4]==cpu and board[6]==cpu or
                board[2]==empty and board[5]==cpu and board[8]==cpu
    ) { board[2] = cpu; }
    else if (   board[6]==empty and board[3]==cpu and board[0]==cpu or
                board[6]==empty and board[4]==cpu and board[2]==cpu or
                board[6]==empty and board[7]==cpu and board[8]==cpu
    ) { board[6] = cpu; }
    else if (   board[8]==empty and board[5]==cpu and board[2]==cpu or
                board[8]==empty and board[4]==cpu and board[0]==cpu or
                board[8]==empty and board[7]==cpu and board[6]==cpu
    ) { board[8] = cpu; }

    else if (   board[1]==empty and board[0]==cpu and board[2]==cpu or
                board[1]==empty and board[4]==cpu and board[7]==cpu
    ) { board[1] = cpu; }
    else if (   board[3]==empty and board[0]==cpu and board[6]==cpu or
                board[3]==empty and board[4]==cpu and board[5]==cpu
    ) { board[3] = cpu; }
    else if (   board[5]==empty and board[2]==cpu and board[8]==cpu or
                board[5]==empty and board[3]==cpu and board[4]==cpu
    ) { board[5] = cpu; }
    else if (   board[7]==empty and board[1]==cpu and board[4]==cpu or
                board[7]==empty and board[6]==cpu and board[8]==cpu
    ) { board[7] = cpu; }
    
    else if (   board[4]==empty and board[1]==cpu and board[7]==cpu or
                board[4]==empty and board[3]==cpu and board[5]==cpu or
                board[4]==empty and board[0]==cpu and board[8]==cpu or
                board[4]==empty and board[2]==cpu and board[6]==cpu
    ) { board[4] = cpu; }

    // if hooman is about to win (two 'X', one empty), prevent
    else if (   board[0]==empty and board[1]==hooman and board[2]==hooman or
                board[0]==empty and board[4]==hooman and board[8]==hooman or
                board[0]==empty and board[3]==hooman and board[6]==hooman
    ) { board[0] = cpu; }
    else if (   board[2]==empty and board[1]==hooman and board[0]==hooman or
                board[2]==empty and board[4]==hooman and board[6]==hooman or
                board[2]==empty and board[5]==hooman and board[8]==hooman
    ) { board[2] = cpu; }
    else if (   board[6]==empty and board[3]==hooman and board[0]==hooman or
                board[6]==empty and board[4]==hooman and board[2]==hooman or
                board[6]==empty and board[7]==hooman and board[8]==hooman
    ) { board[6] = cpu; }
    else if (   board[8]==empty and board[5]==hooman and board[2]==hooman or
                board[8]==empty and board[4]==hooman and board[0]==hooman or
                board[8]==empty and board[7]==hooman and board[6]==hooman
    ) { board[8] = cpu; }

    else if (   board[1]==empty and board[0]==hooman and board[2]==hooman or
                board[1]==empty and board[4]==hooman and board[7]==hooman
    ) { board[1] = cpu; }
    else if (   board[3]==empty and board[0]==hooman and board[6]==hooman or
                board[3]==empty and board[4]==hooman and board[5]==hooman
    ) { board[3] = cpu; }
    else if (   board[5]==empty and board[2]==hooman and board[8]==hooman or
                board[5]==empty and board[3]==hooman and board[4]==hooman
    ) { board[5] = cpu; }
    else if (   board[7]==empty and board[1]==hooman and board[4]==hooman or
                board[7]==empty and board[6]==hooman and board[8]==hooman
    ) { board[7] = cpu; }
    
    else if (   board[4]==empty and board[1]==hooman and board[7]==hooman or
                board[4]==empty and board[3]==hooman and board[5]==hooman or
                board[4]==empty and board[0]==hooman and board[8]==hooman or
                board[4]==empty and board[2]==hooman and board[6]==hooman
    ) { board[4] = cpu; }

    // otherwise, pick the best spot (center > corners > random)
    else if ( board[4]==empty ) { board[4] = cpu; }
    else if ( board[0]==empty ) { board[0] = cpu; }
    else if ( board[2]==empty ) { board[2] = cpu; }
    else if ( board[8]==empty ) { board[8] = cpu; }
    else if ( board[6]==empty ) { board[6] = cpu; }
    else if ( board[1]==empty ) { board[1] = cpu; }
    else if ( board[5]==empty ) { board[5] = cpu; }
    else if ( board[7]==empty ) { board[7] = cpu; }
    else if ( board[3]==empty ) { board[3] = cpu; }
    else {
        // tie
        game = .tie;
    }

    return;
}