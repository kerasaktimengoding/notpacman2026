-- NotPacman.lua

local pacman
local hantu_list = {}
local makanan = {}
local skor
local game_over

function love.load()
    -- Ukuran layar
    love.window.setMode(800, 600)
    
    -- Data Pacman (Pemain)
    pacman = { x = 400, y = 300, radius = 15, speed = 250 }
    
    -- Kosongkan daftar hantu dan makanan (agar aman jika game direstart)
    hantu_list = {}
    makanan = {}
    
    -- Data Hantu (Musuh) - Buat 5 hantu!
    for i = 1, 5 do
        table.insert(hantu_list, { 
            -- Buat hantu muncul acak di pinggir layar agar tidak langsung mengenai Pacman di tengah
            x = math.random(1, 2) == 1 and math.random(10, 150) or math.random(650, 790), 
            y = math.random(1, 2) == 1 and math.random(10, 150) or math.random(450, 590), 
            ukuran = 30, 
            speed = math.random(80, 120) -- Kecepatan tiap hantu sedikit berbeda agar lebih menantang
        })
    end
    
    skor = 0
    game_over = false
    
    -- Buat 50 makanan secara acak di layar
    for i = 1, 50 do
        table.insert(makanan, {
            x = math.random(30, 770),
            y = math.random(30, 570),
            radius = 5
        })
    end
end

function love.update(dt)
    -- Kalau game over atau menang, berhenti bergerak
    if game_over or #makanan == 0 then return end
    
    -- 1. Gerakan Pacman (Atas, Bawah, Kiri, Kanan)
    if love.keyboard.isDown("left") then pacman.x = pacman.x - pacman.speed * dt end
    if love.keyboard.isDown("right") then pacman.x = pacman.x + pacman.speed * dt end
    if love.keyboard.isDown("up") then pacman.y = pacman.y - pacman.speed * dt end
    if love.keyboard.isDown("down") then pacman.y = pacman.y + pacman.speed * dt end
    
    -- Pacman bisa tembus ujung layar (Masuk kanan keluar kiri, dll)
    if pacman.x < 0 then pacman.x = 800 end
    if pacman.x > 800 then pacman.x = 0 end
    if pacman.y < 0 then pacman.y = 600 end
    if pacman.y > 600 then pacman.y = 0 end
    
    -- 2. Ke-5 Hantu mengejar Pacman pelan-pelan
    for _, hantu in ipairs(hantu_list) do
        if hantu.x < pacman.x then hantu.x = hantu.x + hantu.speed * dt
        elseif hantu.x > pacman.x then hantu.x = hantu.x - hantu.speed * dt end
        
        if hantu.y < pacman.y then hantu.y = hantu.y + hantu.speed * dt
        elseif hantu.y > pacman.y then hantu.y = hantu.y - hantu.speed * dt end
    end
    
    -- 3. Pacman Makan (Cek jarak Pacman dengan setiap makanan)
    for i = #makanan, 1, -1 do
        local m = makanan[i]
        local jarakX = pacman.x - m.x
        local jarakY = pacman.y - m.y
        local jarakTotal = math.sqrt(jarakX^2 + jarakY^2)
        
        -- Kalau dekat, makanannya dimakan (dihapus) dan skor bertambah
        if jarakTotal < pacman.radius + m.radius then
            table.remove(makanan, i)
            skor = skor + 10
        end
    end
    
    -- 4. Hantu Menangkap Pacman (Cek satu-satu hantunya)
    for _, hantu in ipairs(hantu_list) do
        local jarakHantuX = pacman.x - hantu.x
        local jarakHantuY = pacman.y - hantu.y
        local jarakHantuTotal = math.sqrt(jarakHantuX^2 + jarakHantuY^2)
        
        -- Kalau jarak hantu dan pacman sangat dekat, Game Over!
        if jarakHantuTotal < pacman.radius + (hantu.ukuran / 2) then
            game_over = true
        end
    end
end

function love.draw()
    -- Gambar Makanan (Titik Putih)
    love.graphics.setColor(1, 1, 1)
    for _, m in ipairs(makanan) do
        love.graphics.circle("fill", m.x, m.y, m.radius)
    end
    
    -- Gambar Pacman (Lingkaran Kuning)
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", pacman.x, pacman.y, pacman.radius)
    
    -- Gambar Hantu (Kotak Merah)
    love.graphics.setColor(1, 0, 0)
    for _, hantu in ipairs(hantu_list) do
        love.graphics.rectangle("fill", hantu.x - (hantu.ukuran/2), hantu.y - (hantu.ukuran/2), hantu.ukuran, hantu.ukuran)
    end
    
    -- Teks Skor
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.print("Skor: " .. skor, 10, 10)
    
    -- Teks Game Over
    if game_over then
        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(love.graphics.newFont(50))
        love.graphics.print("GOBLOOKKKKKK!", 250, 250)
    end
    
    -- Teks Menang
    if #makanan == 0 then
        love.graphics.setColor(0, 1, 0)
        love.graphics.setFont(love.graphics.newFont(50))
        love.graphics.print("MENANG!", 280, 250)
    end
end
