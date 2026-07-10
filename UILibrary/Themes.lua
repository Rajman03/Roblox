-- UILibrary/Themes.lua
-- Dodaj nowy motyw kopiując dowolny blok.
return {
    Default = {
        Bg          = Color3.fromRGB(15,  15,  20),   -- tło okna
        Surface     = Color3.fromRGB(22,  22,  30),   -- topbar / sidebar
        SurfaceAlt  = Color3.fromRGB(28,  28,  38),   -- kafelki elementów
        SurfaceHov  = Color3.fromRGB(36,  36,  50),   -- hover kafelka
        Border      = Color3.fromRGB(46,  46,  64),   -- obramowania
        Accent      = Color3.fromRGB(58,  130, 246),  -- aktywny kolor
        AccentDark  = Color3.fromRGB(28,  76,  180),  -- ciemny akcent (hover)
        AccentOff   = Color3.fromRGB(38,  40,  58),   -- toggle OFF
        TabActive   = Color3.fromRGB(22,  22,  30),   -- aktywna zakładka bg
        TabLine     = Color3.fromRGB(58,  130, 246),  -- linia aktywnej zakładki
        TabInactive = Color3.fromRGB(15,  15,  20),   -- nieaktywna zakładka
        Text        = Color3.fromRGB(220, 220, 235),  -- główny tekst
        TextSub     = Color3.fromRGB(150, 150, 170),  -- drugorzędny tekst
        Muted       = Color3.fromRGB(90,  90,  115),  -- wyciszony tekst
        White       = Color3.fromRGB(255, 255, 255),
        Toggle      = Color3.fromRGB(58,  130, 246),
    },
    Purple = {
        Bg          = Color3.fromRGB(14,  10,  26),
        Surface     = Color3.fromRGB(20,  14,  40),
        SurfaceAlt  = Color3.fromRGB(28,  20,  54),
        SurfaceHov  = Color3.fromRGB(38,  28,  68),
        Border      = Color3.fromRGB(58,  42,  96),
        Accent      = Color3.fromRGB(149,  92, 231),
        AccentDark  = Color3.fromRGB(96,   55, 160),
        AccentOff   = Color3.fromRGB(50,   36,  80),
        TabActive   = Color3.fromRGB(20,  14,  40),
        TabLine     = Color3.fromRGB(149,  92, 231),
        TabInactive = Color3.fromRGB(14,  10,  26),
        Text        = Color3.fromRGB(224, 214, 244),
        TextSub     = Color3.fromRGB(165, 145, 200),
        Muted       = Color3.fromRGB(100,  80, 140),
        White       = Color3.fromRGB(255, 255, 255),
        Toggle      = Color3.fromRGB(149,  92, 231),
    },
}
