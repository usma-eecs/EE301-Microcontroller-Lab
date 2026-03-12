# Arthur Chu USMA/EECS - MIT/LL 2024 - 2026

from adafruit_circuitplayground import cp
import time

#pace = 180;

import math, random

def freq_to_rgb(freq):
    wavelength = (freq*2-500)/1500 * 400 + 380
    return wavelength_to_rgb(wavelength)

def wavelength_to_rgb(wavelength):
    xyz = cie1931_wavelength_to_xyz_fit(wavelength)
    rgb = srgb_xyz_to_rgb(xyz)

    r = int(rgb[0] * 255) & 0xFF
    g = int(rgb[1] * 255) & 0xFF
    b = int(rgb[2] * 255) & 0xFF

    return (r << 16) | (g << 8) | b

def srgb_xyz_to_rgb(xyz):
    x, y, z = xyz

    rl =  3.2406255 * x - 1.537208  * y - 0.4986286 * z
    gl = -0.9689307 * x + 1.8757561 * y + 0.0415175 * z
    bl =  0.0557101 * x - 0.2040211 * y + 1.0569959 * z

    return (
        srgb_xyz_to_rgb_postprocess(rl),
        srgb_xyz_to_rgb_postprocess(gl),
        srgb_xyz_to_rgb_postprocess(bl)
    )

def srgb_xyz_to_rgb_postprocess(c):
    c = max(0, min(1, c))  # Clip to range [0,1]
    return c * 12.92 if c <= 0.0031308 else 1.055 * (c ** (1 / 2.4)) - 0.055

def cie1931_wavelength_to_xyz_fit(wavelength):
    wave = wavelength

    t1 = (wave - 442.0) * (0.0624 if wave < 442.0 else 0.0374)
    t2 = (wave - 599.8) * (0.0264 if wave < 599.8 else 0.0323)
    t3 = (wave - 501.1) * (0.0490 if wave < 501.1 else 0.0382)
    x = 0.362 * math.exp(-0.5 * t1 * t1) + 1.056 * math.exp(-0.5 * t2 * t2) - 0.065 * math.exp(-0.5 * t3 * t3)

    t1 = (wave - 568.8) * (0.0213 if wave < 568.8 else 0.0247)
    t2 = (wave - 530.9) * (0.0613 if wave < 530.9 else 0.0322)
    y = 0.821 * math.exp(-0.5 * t1 * t1) + 0.286 * math.exp(-0.5 * t2 * t2)

    t1 = (wave - 437.0) * (0.0845 if wave < 437.0 else 0.0278)
    t2 = (wave - 459.0) * (0.0385 if wave < 459.0 else 0.0725)
    z = 1.217 * math.exp(-0.5 * t1 * t1) + 0.681 * math.exp(-0.5 * t2 * t2)

    return (x, y, z)


def main():
    # Play a short song using the built-in speaker (at least 20 notes)
    # Reference the provided frequency chart information

    # Example: 440 hz tone played for 1 second.
    # Consider how to use multiple functions for the notes/stanzas...
    #cp.play_tone(440, 1)

    octave = {'x':0, 'C':16.35, 'C#':17.32,'Db': 17.32, 'D': 18.35, 'D#':19.45, 'Eb':19.45,'E':20.6,'F':21.83,'F#':23.12,'Gb':23.12,'G':24.5,'G#':25.96,'Ab':25.96,'A':27.5,'A#':29.14,'Bb':29.14,'B':30.87}

    led = cp.pixels
    led.brightness = 0.05

    while True:
        
        if cp.switch: # checks to see if the switch is on
            cp.red_led = True # Turns the red LED on
        else:
            cp.red_led = False # Turns the red LED off
        
        if cp.button_a:

            #A = 'E-6-1 E-6-1 E-6-.5 D-6-.5 E-6-.5 D-6-1.5 A-4-.5 B-5-1 C-6-.5 x-1 D-6-1 D-6-1 D-6-.5 B-5-.5 D-6-.5 B-5-1.5 E-5-.5 F#-5-1 G-5-1 x-1'
            #B = 'E-6-1 E-6-1 E-6-.5 D-6-.5 E-6-.5 F#-6-1.5 F#-6-1 F#-6-1.5 x-1 D-6-1 D-6-1 D-6-1 D-6-.5 C-6-.5 C-6-.5 B-5-.5 x-1 B-5-.5 B-5-.5 B-5-.5 B-5-3 C-6-1 A-5-2.5 x-.5 A-5-.5 A-5-.5 F#-5-.5 F#-5-.5 F#-5-1.5 B-5-1 F#-5-.5 G-5-3.5 x-1'
            #song = [A,A,B]
            #pace = 180
            p1 = (
                'Bb-4-.5 G-4-.5 Bb-4-1 '
                'Bb-4-.5 G-4-.5 Bb-4-1 '
                'Bb-4-.5 G-4-.5 Bb-4-.75 C-5-.25 Bb-4-.5 G-4-.5 '
                'Bb-4-1 G-4-.5 Ab-4-.5 Bb-4-.5 Ab-4-1 F-4-.5 '
                'Bb-4-.5 Ab-4-1 F-4-.5 Eb-4-3'
            )

            p3 = (
                'Bb-4-.5 Bb-4-.5 Eb-5-1 Eb-5-1 '
                'Bb-4-1.5 Bb-4-.5 C-5-.75 D-5-.25 Eb-5-.5 C-5-.5 '
                'Bb-4-2 Eb-5-.5 Eb-5-1 D-5-.5 '
                'C-5-.75 D-5-.25 Eb-5-.5 C-5-.5 F-5-3'
            )

            p4 = (
                'Bb-4-.5 Bb-4-.5 Eb-5-1 Eb-5-1 '
                'D-5-2 C-5-.75 D-5-.25 Eb-5-.5 C-5-.5 '
                'Bb-4-1 G-4-.5 Ab-4-.5 Bb-4-.5 Ab-4-1 F-4-.5 '
                'Bb-4-.5 Ab-4-1 F-4-.5 Eb-4-3'
            )

            song = [p1, p1, p3, p4]
            pace = 116

        elif cp.button_b:

            hailalmamaterdear = 'C-5-1 Ab-4-.5 F-4-.5 Eb-4-.75 Ab-4-.25 Ab-4-1'
            tousbeevernear = 'Bb-4-1 Ab-4-.5 Bb-4-.5 C-5-.5 F-4-.5 Eb-4-1'
            helpusthymottobear = 'Eb-4-1 D-4-.5 Eb-4-.5 F-4-.5 Db-5-.5 C-5-1'
            throughalltheyears = 'Bb-4-1 C-5-.5 Bb-4-.5 Eb-4-1.5'
            letdutybewellperformed = 'Eb-4-.5 Bb-4-1 C-5-.5 Bb-4-.5 Ab-4-.5 F-4-.5 Eb-4-1'
            honorbeeeruntarned ='C-5-1 Db-5-.5 C-5-.5 F-4-.5 C-5-.5 Bb-4-1'
            countrybeeverarmed='Eb-4-1 F-4-.5 Eb-4-.5 Eb-4-.5 Db-5-.5 C-5-1'
            westpointbytheee = 'Bb-4-1 F-4-1.5 G-4-.5 Ab-4-1.5'

            song = [hailalmamaterdear, tousbeevernear, helpusthymottobear, throughalltheyears, letdutybewellperformed, honorbeeeruntarned, countrybeeverarmed, westpointbytheee]
            pace = 55
        else:            
            if cp.touch_A1: # Checks to see if A1 is being touched
                print("Touched pad A1")
                
                # display the level of light detected
                print("Light level:",(cp.light,)) # waits for 1 second
                x, y, z = cp.acceleration
                print("Acceleration:", (x, y, z))
            if cp.touch_A2:
                print("Touched pad A2")
                magnitude = cp.sound_level
                # Displays that volume magnitude
                print("Sound level:",(magnitude,))

                c_temp = cp.temperature # sample the temperature
                f_temp = c_temp * 1.8 + 32 # Convert the temperature to Fahrenheit

                print("Temp:",(f_temp,)) # Display and plot the temperature
                print("")
            time.sleep(0.1)
            continue
            
        notes = ' '.join(song).split(' ')
        offset = 0
        for i,n in enumerate(notes):
            if not cp.switch:
                break
            parts = n.split('-')
            led.fill((0,0,0))
            if parts[0] == 'x':
                offset += 1
                time.sleep(float(parts[1]) * 60/pace)
            else:
                freq = octave[parts[0]] * (2 ** int(parts[1]))
                rgb = freq_to_rgb(freq)
                ledidx = (i-offset)%10
                led[ledidx] = rgb
                if random.random() > 0.9:
                    led.fill(rgb)
                    #led[ledidx] = (0,0,0)
                cp.play_tone(freq, float(parts[2]) * 60/pace)
                #led.fill((0,0,0))

        led.fill((0,0,0))

main()