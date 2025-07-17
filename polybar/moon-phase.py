#!/bin/python3
# partly yoinked from a js program i found online
import datetime

#phases = ['', '󰽧', '󰽡', '󰽨', '', '󰽦', '󰽣', '󰽥']
phasesMores = [' New Moon', ' New Moon', ' New Moon', ' New Moon', ' New Moon', ' New Moon', ' Waxing Crescent', ' Waxing Crescent', ' Waxing Crescent', ' Waxing Crescent', ' Waxing Crescent', ' Waxing Crescent', '󰽡 First Quarter', '󰽡 First Quarter', '󰽡  First Quarter', '󰽡 First Quarter', '󰽡 First Quarter', '󰽡 First Quarter', ' Waxing Gibbous', ' Waxing Gibbous', ' Waxing Gibbous', ' Waxing Gibbous', ' Waxing Gibbous', ' Waxing Gibbous', ' Full Moon', ' Full Moon', ' Full Moon', ' Full Moon', ' Full Moon', ' Full Moon', ' Waning Gibbous', ' Waning Gibbous', ' Waning Gibbous', ' Waning Gibbous', ' Waning Gibbous', ' Waning Gibbous', '󰽣 Third Quarter', '󰽣 Third Quarter', '󰽣 Third Quarter', '󰽣 Third Quarter', '󰽣 Third Quarter', '󰽣 Third Quarter', ' Waning Crescent', ' Waning Crescent', ' Waning Crescent', ' Waning Crescent', ' Waning Crescent', ' Waning Crescent']

def phase(year, month, day):
    c = e = jd = b = 0

    if month < 3:
      year = year - 1
      month = month + 12

    month = month + 1
    c = 365.25 * year
    e = 30.6 * month
    jd = c + e + day - 694039.09    #jd is total days elapsed
    jd = jd / 29.5305882    # divide by the moon cycle
    b = int(jd)
    jd = jd - b    # subtract integer part to leave fractional part of original jd
    # b = round(jd * 8)    # scale fraction from 0-8 and round
    t = round(jd * 48)   

    if b >= 8:
        b = 0    #0 and 8 are the same so turn 8 into 0

    if t >= 48:
        t = 0

    return phasesMores[t]

today = datetime.date.today()
phaseInfo = phase(today.year, today.month, today.day)
print(phaseInfo[0] + " " + "{0:%B} {0:%d}".format(today))
