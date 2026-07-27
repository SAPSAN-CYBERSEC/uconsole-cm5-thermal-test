#!/usr/bin/env python3
import csv, matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

PHASES=[('idle','dane/idle.csv','Idle'),('stress','dane/stress.csv','100% CPU load (4 cores)'),
        ('cooldown','dane/cooldown.csv','Cooldown'),('video','dane/video.csv','YouTube 1080p')]
series=[]; off=0; bounds=[]
for key,path,label in PHASES:
    rows=[r for r in csv.DictReader(open(path)) if r['temp_c']]
    bounds.append((off/60,label))
    for r in rows:
        series.append((off+int(r['t_s']), float(r['temp_c']),
                       int(r['arm_hz'])//10**6 if r['arm_hz'].isdigit() else None))
    off+=int(rows[-1]['t_s'])+5
x=[s[0]/60 for s in series]; temp=[s[1] for s in series]; mhz=[s[2] for s in series]

fig,(a1,a2)=plt.subplots(2,1,figsize=(12,8),sharex=True,
                         gridspec_kw={'height_ratios':[2,1]})
a1.plot(x,temp,lw=1.8,color='#c0392b',label='SoC temperature')
a1.axhline(80,ls='--',lw=1.2,color='#e67e22',label='Soft throttle limit (80 °C)')
a1.axhline(85,ls='--',lw=1.2,color='#7f0000',label='Hard throttle limit (85 °C)')
a1.axhline(26,ls=':',lw=1,color='#3498db',label='Ambient (26 °C)')
a1.set_ylim(20,90); a1.set_ylabel('SoC temperature [°C]')
a1.set_title('uConsole CM5 — stock case, stock thermal pad, 26 °C ambient, on battery',fontsize=12)
a1.grid(alpha=.25); a1.legend(loc='upper right',fontsize=9,framealpha=0.95)
a1.annotate(f'peak {max(temp):.1f} °C',xy=(x[temp.index(max(temp))],max(temp)),
            xytext=(x[temp.index(max(temp))]+3,max(temp)+8),fontsize=10,
            arrowprops=dict(arrowstyle='->',lw=1))
a2.plot(x,[m if m else float('nan') for m in mhz],lw=1.5,color='#2c3e50')
a2.set_ylabel('ARM clock [MHz]'); a2.set_xlabel('elapsed time [min]')
a2.set_ylim(1400,2500); a2.grid(alpha=.25)
for bx,label in bounds:
    for ax in (a1,a2): ax.axvline(bx,ls=':',lw=1,color='#888')
    a1.text(bx+0.4,30,label,fontsize=9,color='#444')
plt.tight_layout(); plt.savefig('uconsole-cm5-thermal-chart.png',dpi=150)
print('zapisane: uconsole-cm5-thermal-chart.png | probek:',len(series),'| peak:',max(temp),'°C')
