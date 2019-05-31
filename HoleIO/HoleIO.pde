import java.net.Socket;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStreamReader;

/*
 * TODO: game state should be in its own class, for easier sharing
 *       between this thread and the networking thread.
 *       No Nestum BS pls though
 */

Ball player;
ArrayList<TextBox> textboxes = new ArrayList<TextBox>();

int number_of_consumables = 30;
Food[] consumables;
Socket sock;
BufferedReader in;
PrintWriter out;

// 0 -> up ; 1 -> down; 2 -> left; 3 -> right
boolean[] arrows = new boolean[4];

/*
 * TODO: register/login & waiting screen. Maybe different `draw()`
 *       functions, 1 for each state. Maybe login & register can be
 *       the same screen: 2 fields (uname, passwd), 2 buttons (login,
 *       register)
 */
enum Screen {
    login,
    inqueue,
    ingame,
};

Screen screen = Screen.login; /* starts in the login screen */

void setup()
{
    try {
        /* TODO: how do we know when the connection goes down? */
        sock = new Socket("localhost", 4242);
        in = new BufferedReader(new InputStreamReader(sock.getInputStream()));
        out = new PrintWriter(sock.getOutputStream());
    } catch (Exception e) {
        exit();
    }

    BGThread bgt = new BGThread();
    bgt.start();

    size(1200, 700);
    //size(800, 600);

    // USERNAME TextBox
    // CONFIGURED USING THE GLOBAL VARS
    TextBox userTB = new TextBox(160, 103, 200, 35);

    // PASSWORD TextBox
    // CONFIGURED USING THE CLASS CONSTRACTOR
    TextBox passTB = new TextBox(160, 153, 200, 35);
    passTB.BorderWeight = 3;
    passTB.BorderEnable = true;

    textboxes.add(userTB);
    textboxes.add(passTB);

    player = new Ball(100, 100, true);
    consumables = new Food[number_of_consumables];

    /* TODO: this will be done in the server */
    for(int i = 0; i < number_of_consumables; i++) {
        boolean poison_or_not = random(0, 1) > 0.7; // 30% chance of being poison
        consumables[i] = new Food(poison_or_not);
    }

    frameRate(60);
}

void draw()
{
    switch (screen) {
        case login: draw_login(); break;
        case inqueue: draw_inqueue(); break;
        case ingame: draw_ingame(); break;
    }
}

void draw_login ()
{
    background(40, 160, 40);

    // Labels
    fill(250, 250, 250);
    text("LOGIN FORM", (width - textWidth("LOGIN FORM")) / 2, 60);
    textSize(15);
    text("Press Enter to Login", (width - textWidth("Press Enter to Login")) / 2, 80);
    textSize(24);
    text("Username: ", 20, 130);
    text("Password: ", 20, 180);

    // Draw the textboxes
    for (TextBox t : textboxes)
        t.DRAW();
}

void draw_inqueue ()
{
    /* TODO: clean the screen or show smth here so we know were waiting */
    String line = "";
    do {
        try {
            line = in.readLine();
        } catch (Exception e) {
            line = "";
        }
    } while (!line.equals("enter_match"));
    screen = Screen.ingame;
}

void mousePressed() {
    for (TextBox t : textboxes) {
        t.PRESSED(mouseX, mouseY);
    }
}

void draw_ingame ()
{
    /* TODO: communicate with the server */
    background(100);
    player.display();
    movePlayer();

    for(int i = 0; i < number_of_consumables; i++) {
        consumables[i].display();

        float dist = distance(player.getX(), player.getY(), consumables[i].getX(), consumables[i].getY());
        if (dist < player.getRadius()/2 + consumables[i].getSize()/2) {
            player.eats(consumables[i]); /* we dont care if its poison or not, just eat that */
            boolean poison_or_not = random(0, 1) > 0.7;
            consumables[i].pick_location(poison_or_not);
        }
    }
}

// calculates euclidean distance
float distance (int p1x, int p1y, int p2x, int p2y) {
    float p = p2x - p1x;
    float q = p2y - p1y;

    return sqrt(p*p + q*q);
}

void movePlayer ()
{
    if (arrows[0]) player.moveY(-1);
    if (arrows[1]) player.moveY(+1);
    if (arrows[2]) player.moveX(-1);
    if (arrows[3]) player.moveX(+1);
}

void keyPressed ()
{
    switch (screen) {
        case login:
            if (keyCode == ENTER
                    && !textboxes.get(0).Text.equals("")
                    && !textboxes.get(1).Text.equals(""))
            {
                try {
                    String line = "login:" + textboxes.get(0).Text + "\t" + textboxes.get(1).Text;
                    out.println(line);
                    out.flush();

                    line = in.readLine();
                    if (line.equals("ok"))
                        screen = Screen.inqueue;
                } catch (Exception e) {}
            } else {
                for (TextBox t : textboxes)
                    t.KEYPRESSED(key, keyCode);
            }
            break;
        case inqueue: break;
        case ingame:
                      if(keyCode == UP)    arrows[0] = true;
                      if(keyCode == DOWN)  arrows[1] = true;
                      if(keyCode == LEFT)  arrows[2] = true;
                      if(keyCode == RIGHT) arrows[3] = true;
                      break;
    }
}

void keyReleased ()
{
    if(keyCode == UP)    { arrows[0] = false; }
    if(keyCode == DOWN)  { arrows[1] = false; }
    if(keyCode == LEFT)  { arrows[2] = false; }
    if(keyCode == RIGHT) { arrows[3] = false; }
}
