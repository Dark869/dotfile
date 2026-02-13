#!/usr/bin/env python3
import subprocess
import json
import html

try:
    # Verificar si hay algún reproductor activo
    check_result = subprocess.run(['playerctl', '-l'], 
                                capture_output=True, text=True, timeout=1)
    
    if check_result.returncode != 0 or not check_result.stdout.strip():
        # No hay reproductores
        print('{"text": "", "class": "stopped", "alt": "stopped"}')
        exit()
    
    # Obtener estado del reproductor
    status_result = subprocess.run(['playerctl', 'status'], 
                                 capture_output=True, text=True, timeout=1)
    
    if status_result.returncode != 0:
        # No hay reproducción activa
        print('{"text": "", "class": "stopped", "alt": "stopped"}')
        exit()
    
    status = status_result.stdout.strip().lower()
    
    if status == "stopped" or not status:
        # Reproductor detenido
        print('{"text": "", "class": "stopped", "alt": "stopped"}')
        exit()
    
    # Obtener metadatos solo si hay reproducción
    result = subprocess.run(['playerctl', 'metadata', '--format', 
                           '{"text": "{{artist}} - {{title}}", "tooltip": "{{playerName}} : {{artist}} - {{title}}", "alt": "{{status}}", "class": "{{status}}"}'], 
                          capture_output=True, text=True, timeout=1)
    
    if result.returncode == 0 and result.stdout.strip():
        data = json.loads(result.stdout)
        
        # Verificar que hay contenido válido
        if data.get('text') and data['text'].strip() and data['text'] != " - ":
            data['text'] = html.escape(data['text'])
            data['tooltip'] = html.escape(data['tooltip'])
            print(json.dumps(data))
        else:
            print('{"text": "", "class": "stopped", "alt": "stopped"}')
    else:
        print('{"text": "", "class": "stopped", "alt": "stopped"}')
        
except Exception as e:
    print('{"text": "", "class": "stopped", "alt": "stopped"}')
