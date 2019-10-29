--============================================================================--
-- Carrega a largura e a altura da tela
larguraTela = love.graphics.getWidth()
alturaTela = love.graphics.getHeight()
--============================================================================--


--============================================================================--
-- Carrega o que for necessário
function love.load()
  -- Nave {
  imagemNave = love.graphics.newImage("Imagens/Nave Aliada.png")
  nave = {
    posX = larguraTela / 2,
    posY = alturaTela / 2,
    velocidade = 400
  }
  -- } Nave

  -- Tiro {
  podeAtirar = true
  delayTiro = 0.1
  tempoTiro = delayTiro
  tiros = {}
  imagemTiro = love.graphics.newImage("Imagens/Projetil Aliado.png")
  -- } Tiro

  -- Inimigo {
  delayInimigo = 0.8
  tempoCriarInimigo = delayInimigo
  imagemInimigo = love.graphics.newImage("Imagens/Nave Inimiga.png")
  inimigos = {}
  -- } Inimigo

  -- Vidas e pontuação {
  vivo = true
  vidas = 3
  pontos = 0
  -- } Vidas e pontuação

  -- Background {
  background1 = love.graphics.newImage("Imagens/background.png")
  background2 = love.graphics.newImage("Imagens/background.png")

  back = {
    x = 0,
    y = 0,
    y2 = 0 - background1:getHeight(),
    vel = 30
  }
  -- } Background
end
--============================================================================--


--============================================================================--
-- O jogo em si
function  love.update(dt)
  movimentacao(dt)
  atirar(dt)
  inimigo(dt)
  verificaColisao()
  resetar()
  backgroundScroll(dt)
end
--============================================================================--


--============================================================================--
-- Função responsável por fazer a nave do jogador atirar
function atirar(dt)
  tempoTiro = tempoTiro - (1 * dt)
  if tempoTiro < 0 then
    podeAtirar = true
  end

  if vivo then
    if love.keyboard.isDown("space") and podeAtirar then
      novoTiro = {x = nave.posX, y = nave.posY, imagem = imagemTiro}
      table.insert(tiros, novoTiro)
      podeAtirar = false
      tempoTiro = delayTiro
    end
  end

  for i, tiro in ipairs(tiros) do
    tiro.y = tiro.y - (500 * dt)
    if tiro.y < 0 then
      table.remove(tiros, i)
    end
  end
end
--============================================================================--


--============================================================================--
-- Função responsável pela movimentação da nave
function movimentacao(dt)
  if love.keyboard.isDown("right") then
    if nave.posX < (larguraTela - imagemNave:getWidth() / 2) then
      nave.posX = nave.posX + nave.velocidade * dt
    end
  end

  if love.keyboard.isDown("left") then
    if nave.posX > (0 + imagemNave:getWidth() / 2) then
      nave.posX = nave.posX - nave.velocidade * dt
    end
  end

  if love.keyboard.isDown("up") then
    if nave.posY > (0 + imagemNave:getHeight() / 2) then
      nave.posY = nave.posY - nave.velocidade * dt
    end
  end

  if love.keyboard.isDown("down") then
    if nave.posY < (alturaTela - imagemNave:getHeight() / 2) then
      nave.posY = nave.posY + nave.velocidade * dt
    end
  end
end
--============================================================================--


--============================================================================--
-- Função responsável pelas naves inimigos
function inimigo(dt)
  tempoCriarInimigo = tempoCriarInimigo - (1 * dt)
  if tempoCriarInimigo < 0 then
    tempoCriarInimigo = delayInimigo
    numeroAleatorio = math.random(10, love.graphics.getWidth() - ((imagemInimigo:getWidth() / 2) + 10))
    novoInimigo = {x = numeroAleatorio, y = 10, imagem = imagemInimigo}
    table.insert(inimigos, novoInimigo)
  end

  for i, inimigo in ipairs(inimigos) do
    inimigo.y = inimigo.y + (200 * dt)
    if inimigo.y > 850 then
      table.remove(inimigo)
    end
  end
end
--============================================================================--


--============================================================================--
-- Verifica se os objetos estão colidindo e retorna essa informação
function colidindo(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < (x2 + w2) and x2 < (x1 + w1) and y1 < (y2 + h2) and y2 < (y1 + h1)
end
--============================================================================--


--============================================================================--
-- Checa a colisão entre os objetos
function verificaColisao()
  for i, inimigo in ipairs(inimigos) do
    for j, tiro in ipairs(tiros) do
      if colidindo(inimigo.x, inimigo.y, imagemInimigo:getWidth(), imagemInimigo:getHeight(), tiro.x, tiro.y, imagemTiro:getWidth(), imagemTiro:getHeight()) then
        table.remove(tiros, j)
        table.remove(inimigos, i)
        pontos = pontos + 1
      end
    end
  end

  for i, inimigo in ipairs(inimigos) do
    if colidindo(inimigo.x, inimigo.y, imagemInimigo:getWidth(), imagemInimigo:getHeight(), nave.posX - (imagemNave:getWidth() / 2), nave.posY - (imagemNave:getHeight() / 3), imagemNave:getWidth(), imagemNave:getHeight()) and vivo then
      table.remove(inimigos, i)
      vidas = vidas - 1
      estaVivo()
    end
  end
end
--============================================================================--


--============================================================================--
-- Caso as vidas sejam iguais a zero define o jogador como morto
function estaVivo()
  if vidas == 0 then
    vivo = false
  end
end
--============================================================================--


--============================================================================--
function resetar()
  if not vivo and love.keyboard.isDown('r') then
    tiros = {}
    inimigos = {}
    tempoTiro = delayTiro
    tempoCriarInimigo = delayInimigo

    nave.posX = larguraTela / 2
    nave.posY = alturaTela / 2
    vivo = true
    vidas = 3
    pontos = 0
  end
end
--============================================================================--

function backgroundScroll(dt)
  back.y = back.y + back.vel * dt
  back.y2 = back.y2 + back.vel * dt

  if back.y > alturaTela then
    back.y = back.y2 - background2:getHeight()
  end

  if back.y2 > alturaTela then
    back.y2 = back.y - background1:getHeight()
  end
end


--============================================================================--
-- Desenha as imagens na tela
function love.draw()

  -- Background {
  love.graphics.draw(background1, back.x, back.y)
  love.graphics.draw(background2, back.x, back.y2)
  -- } Background


  -- Nave {
  if vivo then
    love.graphics.draw(imagemNave, nave.posX, nave.posY, 0, 0.5, 0.5, imagemNave:getWidth() / 2, imagemNave:getHeight() / 2)
  else
    love.graphics.print("Aperte R para reiniciar", larguraTela / 3, alturaTela / 2)
  end
  -- } Nave

  -- Tiro {
  for i, tiro in ipairs(tiros) do
    love.graphics.draw(tiro.imagem, tiro.x, tiro.y, 0, 0.5, 0.5, imagemTiro:getWidth() / 2, imagemTiro:getHeight() / 2)
  end
  -- } Tiro

  -- Inimigo {
  for i, inimigo in ipairs(inimigos) do
    love.graphics.draw(inimigo.imagem, inimigo.x, inimigo.y, 0, 0.5, 0.5)
  end
  -- } Inimigo

  -- Vida e pontuação {
  if vivo then
    love.graphics.print("Vidas: " .. vidas, 10, 5)
    love.graphics.print("Pontos: " .. pontos, 10, 20)
  end
end
--============================================================================--
