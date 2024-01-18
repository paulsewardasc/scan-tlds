import whois
import datetime


with open('domains.txt') as f:
    lines = f.read().splitlines()

today = datetime.date.today()
for domain in lines:
  w = whois.whois(domain)
  if isinstance(w.expiration_date,datetime.date):
    expiry = w.expiration_date.date()
    diff = expiry - today
    daysleft = diff.days
    print(f'{daysleft}, {domain}, {w.registrar}')
  elif isinstance(w.expiration_date,list):
    expiry = w.expiration_date[0].date()
    diff = expiry - today
    daysleft = diff.days
    print(f'{daysleft}, {domain}, {w.registrar}')
  else:
    print(f'{domain}: {w.expiration_date}, {w.registrar}')


