#!/bin/bash
#
# Author  : Sylvain Deguire (VA2OPS)
# Date    : January 2025
# Purpose : Configuration for EmComm-Tools Ham Radio Wiki builder

# Wiki metadata
export WIKI_NAME="EmComm Ham Radio Encyclopedia"
export WIKI_TITLE="Ham Radio Encyclopedia"
export WIKI_DESCRIPTION="Offline reference for amateur radio operators - digital modes, antennas, electronics, emergency communications"
export WIKI_LANGUAGE="eng"
export WIKI_CREATOR="EmComm-Tools Project"
export WIKI_PUBLISHER="VA2OPS"
export WIKI_FAVICON="content/images/favicon.png"
export WIKI_MAIN_PAGE="index.html"

# Build settings
export BUILD_DATE=$(date +%Y%m%d)
export OUTPUT_DIR="output"
export OUTPUT_FILE="emcomm-ham-wiki_${BUILD_DATE}.zim"
export CONTENT_DIR="content/articles"

# Wikipedia API settings (for fetching articles)
export WIKIPEDIA_API="https://en.wikipedia.org/w/api.php"
export WIKIPEDIA_LANG="en"

# Articles to fetch from Wikipedia (space-separated)
export WIKIPEDIA_ARTICLES="
Amateur_radio
Amateur_radio_frequency_allocations
Shortwave_bands
High_frequency
Very_high_frequency
Ultra_high_frequency
Radio_propagation
Skywave
Ground_wave
Near_vertical_incidence_skywave
Sporadic_E_propagation
Tropospheric_propagation
Antenna_(radio)
Dipole_antenna
Yagi-Uda_antenna
Vertical_antenna
Loop_antenna
End-fed_antenna
Balun
Standing_wave_ratio
Impedance_matching
Coaxial_cable
RF_connector
Amateur_radio_licensing
Call_sign
Phonetic_alphabet
Q_code
RST_code
QSO
Amateur_radio_operator
Ham_radio_contesting
Amateur_radio_emergency_communications
Automatic_Packet_Reporting_System
Packet_radio
AX.25
Winlink
JS8Call
WSJT-X
FT8
FT4_(amateur_radio_mode)
PSK31
RTTY
Fldigi
Direwolf_(software)
Software-defined_radio
RTL-SDR
Transceiver
Amateur_radio_transceiver
Icom
Yaesu_(brand)
Kenwood_Corporation
Digital_mode_(amateur_radio)
Sound_card_interface
CAT_(Computer_Aided_Transceiver)
Ohms_law
Decibel
Electronic_filter
Low-pass_filter
Dummy_load
Power_supply
Solar_cycle
Sunspot
K-index
A-index
Solar_flux_unit
Ionosphere
"

# Content categories
export CATEGORIES="bandplans digital-modes software radios antennas electronics emcomm propagation reference"
