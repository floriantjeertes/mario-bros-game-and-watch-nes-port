  .inesprg 1    ; Defines the number of 16kb PRG banks
  .ineschr 1    ; Defines the number of 8kb CHR banks
  .inesmap 0    ; Defines the NES mapper
  .inesmir 1    ; Defines VRAM mirroring of banks

  .rsset $0000  ;sets var in memory at address $000
pointerBackgroundLowByte  .rs 1
pointerBackgroundHighByte .rs 1
shipTile1Y = $0300
shipTile2Y = $0304
shipTile3Y = $0308
shipTile4Y = $030C
shipTile5Y = $0310
shipTile6Y = $0314

shipTile1X = $0303
shipTile2X = $0307
shipTile3X = $030B
shipTile4X = $030F
shipTile5X = $0313
shipTile6X = $0317

UpPressed   =  $0001
DownPressed =  $0002
  .bank 0 ;define memory  bank 0
  .org $C000 ;bank $c000 start

RESET:
 JSR LoadBackground ;jumps to sub routine LoadBackground to run it and returns here when done (basicly a function)
 JSR LoadPallets
 JSR LoadAtributes
 JSR LoadSprites


 LDA #%10000000   ; Enable NMI, sprites and background on table 0 %means you canuse binairy
 STA $2000
 LDA #%00011110   ; Enable sprites, enable backgrounds %means you canuse binairy
 STA $2001
 LDA #$00        ; No background scrolling
 STA $2006
 STA $2006
 STA $2005
 STA $2005

InfiniteLoop:
  JMP  InfiniteLoop ;springs to label InfiniteLoop

LoadBackground:
 LDA $2002 ;LoaD Acumulator  loads vallue from address $2002 into acumulator
 LDA #$20  ;LoaD Acumulator  loads vallue #$20 into acumulator
 STA $2006 ; STore acumulator takes value from acumulator into memory address $2006(PPU "picture processing unit")
 LDA #$00
 STA $2006

 LDA #LOW(background) ;#low is function of nesasm
 STA pointerBackgroundLowByte ;loads the low byte into var pointerBackgroundLowByte
 LDA #HIGH(background) ;
 STA pointerBackgroundHighByte

 LDX #$00
 LDY #$00
.Loop:
  LDA [pointerBackgroundLowByte], y
  STA $2007 ;stores memmory in the adres of the ppu that writes a tile on the screan

  INY ;increments the byte stored in y
  CPY #$00
  BNE .Loop ;Branch if Not Equal loops if the vallue is not 0

  INC pointerBackgroundHighByte ;increments pointerBackgroundHighByte
  INX
  CPX #$04
  BNE .Loop
  RTS ;ReTurn to Subroutine end of function

  LoadPallets:
   LDA $2002
   LDA #$3F
   STA $2006
   LDA #$00
   STA $2006

   LDX #$00
  .Loop:
   LDA palettes, x
   STA $2007
   INX
   CPX #$20
   BNE .Loop
   RTS

  LoadAtributes:
  LDA $2002
  LDA #$23
  STA $2006
  LDA #$C0
  STA $2006
  LDX #$00
  .Loop:
  LDA attributes, x
  STA $2007
  INX
  CPX #$40
  BNE .Loop
  RTS

 LoadSprites:
  LDX #$00
 .Loop:
  LDA sprites, x
  STA $0300, x
  INX
  CPX #$18
  BNE .Loop
  RTS
 ReadPlayerOneControls:
 LDA #$01
 STA $4016
 LDA #$00
 STA $4016

  LDA $4016       ; Player 1 - A
  LDA $4016       ; Player 1 - B
  LDA $4016       ; Player 1 - Select
  LDA $4016       ; Player 1 - Start


 ReadUp:
 LDA $4016 ;player one up
 AND #%00000001
 BEQ EndReadUp
 LDA #$01
 STA UpPressed
 EndReadUp:


 SpriteUp:
 LDA UpPressed
 AND #$01
 BEQ EndSpriteUp


 LDA shipTile1Y
 SEC
 SBC #$01
 STA shipTile1Y

 LDA shipTile2Y
 SEC
 SBC #$01
 STA shipTile2Y

 LDA shipTile3Y
 SEC
 SBC #$01
 STA shipTile3Y

 LDA shipTile4Y
 SEC
 SBC #$01
 STA shipTile4Y

 LDA  #$00
 STA UpPressed

EndSpriteUp:

ReadDown:
 LDA $4016 ;read down
 AND #%00000001
 BEQ EndReadDown
 LDA #$01
 STA DownPressed
 EndReadDown:


 SpriteDown:
 LDA DownPressed
 AND #$01
 BEQ EndSpriteDown

 LDA shipTile1Y
 CLC
 ADC #$01
 STA shipTile1Y

 LDA shipTile2Y
 CLC
 ADC #$01
 STA shipTile2Y

 LDA shipTile3Y
 CLC
 ADC #$01
 STA shipTile3Y

 LDA shipTile4Y
 CLC
 ADC #$01
 STA shipTile4Y

 LDA  #$00
 STA  DownPressed
 EndSpriteDown:

 ReadLeft:
  LDA $4016
  AND #%00000001
  BEQ EndReadLeft

  LDA shipTile1X
  SEC
  SBC #$01
  STA shipTile1X
  STA shipTile4X

  LDA shipTile2X
  SEC
  SBC #$01
  STA shipTile2X
  STA shipTile5X

  LDA shipTile3X
  SEC
  SBC #$01
  STA shipTile3X
  STA shipTile6X
  EndReadLeft:

  ReadRight:
  LDA $4016
  AND #%00000001
  BEQ EndReadRight

  LDA shipTile1X
  CLC
  ADC #$01
  STA shipTile1X
  STA shipTile4X

  LDA shipTile2X
  CLC
  ADC #$01
  STA shipTile2X
  STA shipTile5X

  LDA shipTile3X
  CLC
  ADC #$01
  STA shipTile3X
  STA shipTile6X
  EndReadRight:

  RTS
  NMI:
   LDA #$00
   STA $2003
   LDA #$03
   STA $4014

  JSR ReadPlayerOneControls
  RTI ;end of game loop (ReTurn from Interupt)

 .bank 1 ;define memory bank 1
 .org $E000 ; mem adress $E000
background:
 .include "/Users/florianmac/Documents/projects/nes game/exercise/graphics/background.asm"
palettes:
 .include "/Users/florianmac/Documents/projects/nes game/exercise/graphics/palettes.asm"
attributes:
 .include "/Users/florianmac/Documents/projects/nes game/exercise/graphics/attributes.asm"
sprites:
  .include "/Users/florianmac/Documents/projects/nes game/exercise/graphics/sprites.asm"


 .org $FFFA ;memory adress $FFFA
 .dw NMI    ;Data Word  (2 bytes big)
 .dw RESET
 .dw 0

 .bank 2    ;defines 2
 .org $0000  ;and start of graphics bank at memory address $0000
 .incbin "/Users/florianmac/Documents/projects/nes game/exercise/graphics2.chr"
