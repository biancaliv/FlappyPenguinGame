import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioPlayer menuMusic;
AudioPlayer gameMusic;
AudioPlayer jumpSound;

int game, score, highscore, x, y, vertical;
int[] wallx = new int[2];
int[] wally = new int[2];
boolean[] passedWall = new boolean[2]; // Variável para controlar se o pinguim passou a parede
float difficulty; // Variável para controlar a dificuldade

PImage img, img2, img3, img4, imgMenu;

void setup() {
  minim = new Minim(this);

  // Carregar as músicas
  menuMusic = minim.loadFile("menu.mp3");
  gameMusic = minim.loadFile("emgame.mp3");
  jumpSound = minim.loadFile("pulo.mp3");

  // Ajustar o volume
  menuMusic.setGain(-30); // Reduzir o volume em 30 dB
  gameMusic.setGain(-30); // Reduzir o volume em 30 dB
  jumpSound.setGain(-10); // Reduzir o volume em 10 dB

  game = 1; // Começar no menu principal
  score = 0;
  highscore = 0;
  x = -200;
  vertical = 0;
  difficulty = 0.5; // Inicializar a dificuldade menor
  size(600, 800);
  fill(0, 0, 0);
  textSize(20);

  // Carregar imagens
  img = loadImage("fundo.png");
  img2 = loadImage("penguim.png");
  img3 = loadImage("wall.png");
  img4 = loadImage("welcome.jpg");
  imgMenu = loadImage("fotomenu.jpg");

  // Tocar música do menu
  menuMusic.loop();
}

void draw() {
  if (game == 0) {
    // Verificar se a música de fundo do jogo está tocando, se não, tocar
    if (!gameMusic.isPlaying()) {
      gameMusic.loop();
      menuMusic.pause(); // Pausar música do menu
    }

    // Aumentar a dificuldade ao longo do tempo
    difficulty += 0.002;

    imageMode(CORNER);
    image(img, x, 0);
    image(img, x + img.width, 0);
    x -= 3 * difficulty; // Aumentar a velocidade de fundo conforme a dificuldade
    vertical += 1; // Gravidade padrão
    y += vertical;
    if (x <= -img.width) x = 0;

    for (int i = 0; i < 2; i++) {
      imageMode(CENTER);
      image(img3, wallx[i], wally[i] - (img3.height / 2 + 100));
      image(img3, wallx[i], wally[i] + (img3.height / 2 + 100));
      if (wallx[i] < 0) {
        wally[i] = (int)random(200, height - 200);
        wallx[i] = width;
      }
      println(wallx[i]);
      if (wallx[i] >= (width-2 / 2) && wallx[i] <= (width+2 / 2)) highscore = max(++score, highscore);
      if (y > height || y < 0 || (abs(width / 2 - wallx[i]) < 25 && abs(y - wally[i]) > 100)) game = 1;
      wallx[i] -= 6 * difficulty; // Aumentar a velocidade das paredes conforme a dificuldade 
      }

    image(img2, width / 2, y);
    text("Score: " + score, 10, 20);
  } else if (game == 1) {
    // Verificar se a música do menu está tocando, se não, tocar
    if (!menuMusic.isPlaying()) {
      menuMusic.loop();
      gameMusic.pause(); // Pausar música do jogo
    }

    imageMode(CORNER);
    image(imgMenu, 0, 0, width, height);

    fill(0, 0, 139); // Azul escuro
    textSize(40);
    textAlign(CENTER, CENTER);

    // Texto com bordas brancas
    drawTextWithBorder("Flappy Penguin", width / 2, height / 2 - 300, 4);
    textSize(30);
    drawTextWithBorder("Jogar", width / 2, height / 2 - 220, 3); // Mover ainda mais para cima
    drawTextWithBorder("Como Jogar", width / 2, height / 2 - 150, 3); // Mover ainda mais para cima
    drawTextWithBorder("Créditos", width / 2, height / 2 - 80, 3); // Mover ainda mais para cima
    drawTextWithBorder("High Score: " + highscore, width / 2, height / 2 + 210, 3); // Mostrar o High Score
  } else if (game == 2) {
    background(0, 0, 139);
    fill(255);
    textSize(30);
    textAlign(CENTER, CENTER);
    text("Comandos:", width / 2, height / 2 - 100);
    text("Clique para pular", width / 2, height / 2);

    textSize(18);
    text("Clique para voltar", width / 2, height / 2 + 100);
  } else if (game == 3) {
    background(0, 0, 139);
    fill(255);
    textSize(30);
    textAlign(CENTER, CENTER);
    text("Créditos:", width / 2, height / 2 - 100);
    text("Amanda de Jesus Veloso", width / 2, height / 2 - 50);
    text("Bianca Oliveira Moreira", width / 2, height / 2);
    text("Thiago Almeida Bueno", width / 2, height / 2 + 50);

    textSize(18);
    text("Clique para voltar", width / 2, height / 2 + 100);
  }
}

void drawTextWithBorder(String text, float x, float y, float borderSize) {
  fill(255); // Cor da borda branca
  text(text, x - borderSize, y);
  text(text, x + borderSize, y);
  text(text, x, y - borderSize);
  text(text, x, y + borderSize);

  text(text, x - borderSize, y - borderSize);
  text(text, x + borderSize, y - borderSize);
  text(text, x - borderSize, y + borderSize);
  text(text, x + borderSize, y + borderSize);

  fill(0, 0, 139); // Cor do texto azul escuro
  text(text, x, y);
}

void mousePressed() {
  if (game == 0) {
    vertical = -12; // Força do pulo diminuída
    jumpSound.rewind(); // Rebobinar o som do pulo para o início
    jumpSound.play();   // Tocar o som do pulo
  } else if (game == 1) {
    if (mouseX > width / 2 - 100 && mouseX < width / 2 + 100) {
      if (mouseY > height / 2 - 230 && mouseY < height / 2 - 180) { // Ajuste de Y para o novo posicionamento
        // Jogar
        wallx[0] = 600;
        wally[0] = y = height / 2;
        wallx[1] = 900;
        wally[1] = 600;
        x = score = 0;
        vertical = 0; // Certifique-se de que o movimento vertical seja resetado
        difficulty = 0.5; // Resetar a dificuldade
        passedWall[0] = passedWall[1] = false; // Resetar o controle de passagem das paredes
        game = 0; // Começar o jogo
      } else if (mouseY > height / 2 - 160 && mouseY < height / 2 - 110) { // Ajuste de Y
        // Como Jogar
        game = 2;
      } else if (mouseY > height / 2 - 90 && mouseY < height / 2 - 40) { // Ajuste de Y
        // Créditos
        game = 3;
      }
    }
  } else if (game == 2 || game == 3) {
    game = 1; // Voltar ao menu principal
  }
}
