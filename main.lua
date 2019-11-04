--============================================================================--
-- Carrega a largura e a altura da tela
larguraTela = love.graphics.getWidth()
alturaTela = love.graphics.getHeight()
--============================================================================--


--============================================================================--
-- Carrega o que for necessário
function love.load()
    -- Nave ----------------------------------------------------------------------
    imagemNave = love.graphics.newImage("Imagens/Nave Aliada.png") -- Carrega a imagem da nave do jogador
    nave = { -- Carrega as propriedades da nave do jogador
        posX = larguraTela / 2, -- A posição X da nave do jogador é definida para o centro da tela
        posY = alturaTela / 2, -- A posição Y da nave do jogador é definida para o centro da tela
        velocidade = 400 -- Define a velocidade de movimento da nave do jogador
    }
    ------------------------------------------------------------------------------

    -- Tiro ----------------------------------------------------------------------
    podeAtirar = true
    delayTiro = 0.1
    tempoTiro = delayTiro
    tiros = {}
    imagemTiro = love.graphics.newImage("Imagens/Projetil Aliado.png")
    ------------------------------------------------------------------------------

    -- Inimigo -------------------------------------------------------------------
    delayInimigo = 0.8
    tempoCriarInimigo = delayInimigo
    imagemInimigo = love.graphics.newImage("Imagens/Nave Inimiga.png")
    inimigos = {}
    velocidadeInimigo = 200
    ------------------------------------------------------------------------------

    -- Vidas e pontuação ---------------------------------------------------------
    vivo = true
    vidas = 3
    pontos = 0
    ------------------------------------------------------------------------------

    -- Background ----------------------------------------------------------------
    background1 = love.graphics.newImage("Imagens/background.png")
    background2 = love.graphics.newImage("Imagens/background.png")

    back = {
        x = 0,
        y = 0,
        y2 = 0 - background1:getHeight(),
        vel = 30
    }
    ------------------------------------------------------------------------------

    -- Fonte ---------------------------------------------------------------------
    font = love.graphics.newFont("fonte.ttf", 18)
    ------------------------------------------------------------------------------
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
    if love.keyboard.isDown("right") then -- Quando a seta para direita estiver pressionada
        if nave.posX < (larguraTela) then -- Delimita a área de movimentação com o máximo da largura da tela (larguraTela - imagemNave:getWidth())
            nave.posX = nave.posX + nave.velocidade * dt -- Movimenta a nave positivamente no eixo X
        end
    end

    if love.keyboard.isDown("left") then -- Quando a seta para esquerda estiver pressionada
        if nave.posX > (0) then -- Delimita a área de movimentação com o mínimo de 0 (0 + imagemNave:getWidth())
            nave.posX = nave.posX - nave.velocidade * dt -- Movimenta a nave negativamente no eixo X
        end
    end

    if love.keyboard.isDown("up") then -- Quando a seta para cima estiver pressionada
        if nave.posY > (0) then -- Delimita a área de movimentação com o mínimo de 0
            nave.posY = nave.posY - nave.velocidade * dt -- Movimenta a nave positivamente no eixo Y
        end
    end

    if love.keyboard.isDown("down") then -- Quando a seta para baixo estiver pressionada
        if nave.posY < (alturaTela) then -- Delimita a área de movimentação com o máximo da altura da tela
            nave.posY = nave.posY + nave.velocidade * dt -- Movimenta a nave negativamente no eixo Y
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
        numeroAleatorio = math.random(10, love.graphics.getWidth() - ((imagemInimigo:getWidth() / 4)))
        novoInimigo = {x = numeroAleatorio, y = 0, imagem = imagemInimigo}
        table.insert(inimigos, novoInimigo)
    end

    for i, inimigo in ipairs(inimigos) do
        inimigo.y = inimigo.y + (velocidadeInimigo * dt)
        if inimigo.y > 850 then
            table.remove(inimigo)
        end
    end
end
--============================================================================--


--============================================================================--
-- Verifica se os objetos estão colidindo e retorna essa informação
function colidindo(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < (x2 + (w2 / 2)) and x2 < (x1 + (w1 / 2)) and y1 < (y2 + (h2 / 2)) and y2 < (y1 + (h1 / 2))
end
--============================================================================--


--============================================================================--
-- Checa a colisão entre os objetos chamando a função colidindo()
function verificaColisao()
    for i, inimigo in ipairs(inimigos) do
        for j, tiro in ipairs(tiros) do
            if colidindo(inimigo.x, inimigo.y, imagemInimigo:getWidth(), imagemInimigo:getHeight(), tiro.x, tiro.y, imagemTiro:getWidth(), imagemTiro:getHeight()) then
                table.remove(inimigos, i)
                table.remove(tiros, j)
                pontos = pontos + 1
            end
        end
    end

    for i, inimigo in ipairs(inimigos) do
        if colidindo(inimigo.x, inimigo.y, imagemInimigo:getWidth(), imagemInimigo:getHeight(), nave.posX, nave.posY, imagemNave:getWidth(), imagemNave:getHeight()) and vivo then
            table.remove(inimigos, i)
            vidas = vidas - 1
            estaVivo()
        end
    end
end
--============================================================================--


--============================================================================--
-- Verifica o número de vidas e caso as vidas sejam iguais a zero seta o
-- jogador como morto
function estaVivo()
    if vidas == 0 then
        vivo = false
    end
end
--============================================================================--


--============================================================================--
-- Reseta o jogo setando as variáveis de cenário para o valor padrão
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
--
--============================================================================--
-- Faz com que o background de fundo se movimente dando a impressão de que a
-- nave está em movimento
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


--============================================================================--
-- Desenha as imagens na tela
function love.draw()
    -- Fonte ---------------------------------------------------------------------
    love.graphics.setFont(font)


    -- Background ----------------------------------------------------------------
    love.graphics.draw(background1, back.x, back.y)
    love.graphics.draw(background2, back.x, back.y2)
    ------------------------------------------------------------------------------

    -- Nave ----------------------------------------------------------------------
    if vivo then
        love.graphics.draw(imagemNave, nave.posX, nave.posY, 0, 0.5, 0.5, imagemNave:getWidth() / 2, imagemNave:getHeight() / 2)
    else
        love.graphics.print("Aperte R para reiniciar", larguraTela / 3, alturaTela / 2)
    end
    ------------------------------------------------------------------------------

    -- Tiro ----------------------------------------------------------------------
    for i, tiro in ipairs(tiros) do
        love.graphics.draw(tiro.imagem, tiro.x, tiro.y, 0, 0.5, 0.5, imagemTiro:getWidth() / 2, imagemTiro:getHeight() / 2)
    end
    ------------------------------------------------------------------------------

    -- Inimigo -------------------------------------------------------------------
    for i, inimigo in ipairs(inimigos) do
        love.graphics.draw(inimigo.imagem, inimigo.x, inimigo.y, 3.14159, 0.5, 0.5)
    end
    ------------------------------------------------------------------------------

    -- Vida e pontuação ----------------------------------------------------------
    if vivo then
        love.graphics.print("Vidas: " .. vidas, 10, 5)
        love.graphics.print("Pontos: " .. pontos, 10, 20)
    end
    ------------------------------------------------------------------------------
end
--============================================================================--
