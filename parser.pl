
#!/usr/bin/perl

#Copyright 2013 George D. Nincehelser

$celsius        = '0';
$farenheit      = '0';
$humidity       = '0';
$windspeed      = '0';
$winddir        = '0';
$rainfall       = '0';
$raintotal      = '0';
$pressure       = '0';
$pressure_in    = '0';

while ($line = <STDIN> )

{ 

$index = index ($line, 'mt=pressure');
if ($index != -1)
        {
        $c1 = substr $line, index ($line, 'C1=') + 3, 4;
        $c2 = substr $line, index ($line, 'C2=') + 3, 4;
        $c3 = substr $line, index ($line, 'C3=') + 3, 4;
        $c4 = substr $line, index ($line, 'C4=') + 3, 4;
        $c5 = substr $line, index ($line, 'C5=') + 3, 4;
        $c6 = substr $line, index ($line, 'C6=') + 3, 4;
        $c7 = substr $line, index ($line, 'C7=') + 3, 4;
        $a  = substr $line, index ($line, 'A=') + 2, 2;
        $b  = substr $line, index ($line, 'B=') + 2, 2;
        $c  = substr $line, index ($line, 'C=') + 2, 2;
        $d  = substr $line, index ($line, 'D=') + 2, 2;
        $pr = substr $line, index ($line, 'PR=') + 3, 4;
        $tr = substr $line, index ($line, 'TR=') + 3, 4;

        $c1 = hex ($c1);
        $c2 = hex ($c2);
        $c3 = hex ($c3);
        $c4 = hex ($c4);
        $c5 = hex ($c5);
        $c6 = hex ($c6);
        $c7 = hex ($c7);
        $a  = hex ($a);
        $b  = hex ($b);
        $c  = hex ($c);
        $d  = hex ($d);
        $pr = hex ($pr);
        $tr = hex ($tr);

        $d1 = $pr;
        $d2 = $tr;

        if ($d2 >= $c5)
                {
                $dut = $d2-$c5-(($d2-$c5)/2**7) * (($d2-$c5)/2**7)*$a/2**$c;
                }
                else
                {
                $dut = $d2-$c5-(($d2-$c5)/2**7) * (($d2-$c5)/2**7)*$b/2**$c;
                };

        $off = ($c2 + ($c4 - 1024) * $dut / 2**14) * 4;
        $sens = $c1 + $c3 * $dut / 2**10;
        $x = $sens * ($d1 - 7168) / 2**14 - $off;
        $p = $x * 10 / 2**5 + $c7 + 760;

        $t = 250 + $dut*$c6/2**16-$dut/2**$d;

        $pressure = sprintf ("%.0f", $p / 10);
        $pressure_in = sprintf ("%.2f", $p / 338.6 );
        };

#
# Wind direction is reported as a single hex digit
# Also seems to be using a non-standard Gray Code
# 
      $index = index ($line, 'winddir');
        if ($index != -1)
            {
            $winddir_frag = substr $line, $index + 8, 1;
            if ($winddir_frag eq '5' )
                {$winddir = 0 };
            if ($winddir_frag eq '7' )
                {$winddir = 22.5 };
            if ($winddir_frag eq '3' )
                {$winddir = 45 };
            if ($winddir_frag eq '1' )
                {$winddir = 67.5 };
            if ($winddir_frag eq '9' )
                {$winddir = 90 };
            if ($winddir_frag eq 'B' )
                {$winddir = 112.5 };
            if ($winddir_frag eq 'F' )
                {$winddir = 135 };
            if ($winddir_frag eq 'D' )
                {$winddir = 157.5 };
            if ($winddir_frag eq 'C' )
                {$winddir = 180 };
            if ($winddir_frag eq 'E' )
                {$winddir = 202.5 };
            if ($winddir_frag eq 'A' )
                {$winddir = 225 };
            if ($winddir_frag eq '8' )
                {$winddir = 247.5 };
            if ($winddir_frag eq '0' )
                {$winddir = 270 };
            if ($winddir_frag eq '2' )
                {$winddir = 292.5 };
            if ($winddir_frag eq '6' )
                {$winddir = 315 };
            if ($winddir_frag eq '4' )
                {$winddir = 337.5 };
            };

$index = index ($line, 'rainfall');
if ($index != -1)
        {
        $rainfall_frag = substr $line, $index + 10, 6;
        $rainfall = $rainfall_frag / 2540;
        $raintotal = $raintotal + $rainfall;
        };

#
# Wind speed is reported as centimeters per second
# Convert to miles per hour by dividing by 44.7
# Rounded to nearest MPH
#

$index = index ($line, 'windspeed');
if ($index != -1)
        {
        $wind_frag = substr $line, $index + 11, 5;
        $windspeed = sprintf ("%.0f", $wind_frag / 44.7);
        };

if (index ($line, 'temperature') != -1)
        {
        $temp_frag = substr $line, index ($line, 'temperature') + 13, 4;
        $celsius = $temp_frag / 10;
        $farenheit = $celsius * 9/5 + 32;
        };

if (index ($line, 'humidity') != -1)
        {
        $humid_frag = substr $line, index ($line, 'humidity') + 11, 3;
        $humidity = $humid_frag / 10;
        };

print "\033[2J";    #clear the screen
print "\033[0;0H"; #jump to 0,0

use POSIX qw(strftime);
print strftime("%a, %d %b %Y %H:%M:%S %z", localtime(time())) . "\n";

print "\n $line \n";
print "temperature F = $farenheit\n";
print "humidity % = $humidity\n";
print "wind speed MPH = $windspeed\n";
print "wind direction degrees = $winddir\n";
print "rain in last 36 seconds inches = $rainfall\n";
print "total rain since last restart inches = $raintotal\n";
print "absolute pressure in mmHg = $pressure\n";
print "absolute pressure in inHg = $pressure_in\n";

open (MYFILE, '>/home/ipwx/wxdata');
print MYFILE "temp = $farenheit\n";
print MYFILE "humi = $humidity\n";
print MYFILE "baro = $pressure_in\n";
print MYFILE "wspd = $windspeed\n";
print MYFILE "wdir = $winddir\n";
print MYFILE "rain = $rainfall\n";
close (MYFILE);

open (MYFILE, '>/home/ipwx/temp');
print MYFILE "$celsius\n";
close (MYFILE)

};
