#!/usr/bin/python
import os
import sys
import urllib.parse


def main(url: str):
    u = urllib.parse.urlparse(url)
    # print(u)
    # with open('/home/michael/browse.log', 'a') as f:
    #     f.write(urllib.parse.urlunparse(u))
    #     f.write('\n')
    #     f.write(str(u))
    #     f.write('\n')
    if u.netloc == 'www.google.com' and u.path == '/url':
        # de-google
        q = urllib.parse.parse_qs(u.query)
        if 'q' in q:
            u = urllib.parse.urlparse(q['q'][0])
        elif 'url' in q:
            u = urllib.parse.urlparse(q['url'][0])
        # print(urllib.parse.urlunparse(u))
        # print(u)
        with open('/home/michael/browse.log', 'a') as f:
            f.write(urllib.parse.urlunparse(u))
            f.write('\n')
            f.write(str(u))
            f.write('\n')
    if u.scheme == 'msteams' or u.netloc == 'teams.microsoft.com':
        os.execvp('teams-for-linux', ['teams-for-linux', '--closeAppOnCross', '--url', urllib.parse.urlunparse(u)])
    elif u.netloc == 'meet.google.com':
        os.execvp('firefoxpwa', ['firefoxpwa', 'site', 'launch', '01G2T0C6M0XE8HN8XWN830KWX0', '--url', urllib.parse.urlunparse(u)])
    elif u.scheme == 'zoommtg':
        q = urllib.parse.parse_qs(u.query)
        u = urllib.parse.ParseResult('https', u.netloc, f'/wc/join/{q["confno"][0]}', u.params, u.query, u.fragment)
        with open('/home/michael/browse.log', 'a') as f:
            f.write(urllib.parse.urlunparse(u))
            f.write('\n')
            f.write(str(u))
            f.write('\n')
        os.execvp('firefoxpwa', ['firefoxpwa', 'site', 'launch', '01G2T19AZ8DK1FTW8DQDCY350M', '--url', urllib.parse.urlunparse(u)])
    elif u.netloc == 'zoom.us' or u.netloc.partition('.')[2] == 'zoom.us':
        if u.path.startswith('/j/'):
            u = urllib.parse.ParseResult(u.scheme, u.netloc, u.path.replace('/j/', '/wc/join/'), u.params, u.query, u.fragment)
            with open('/home/michael/browse.log', 'a') as f:
                f.write(urllib.parse.urlunparse(u))
                f.write('\n')
                f.write(str(u))
                f.write('\n')
        os.execvp('firefoxpwa', ['firefoxpwa', 'site', 'launch', '01G2T19AZ8DK1FTW8DQDCY350M', '--url', urllib.parse.urlunparse(u)])
    else:
        with os.popen('swaymsg -t get_tree') as f:
            if 'firefox' in f.read():
                os.execvp('firefox', ['firefox', urllib.parse.urlunparse(u)])
            else:
                os.execvp('vivaldi-stable', ['vivaldi-stable', urllib.parse.urlunparse(u)])


if __name__ == '__main__':
    main(sys.argv[1])
