import json
import re
import io

en_keys = {
    'About Us': 'About Us',
    '1. Introduction': '1. Introduction',
    'Clean Ethiopia is a digital initiative by the Environmental Protection Authority (EPA) designed to make environmental protection accessible to everyone. Our goal is simple — to empower citizens to report pollution, illegal waste disposal, deforestation, and other environmental violations directly from their mobile devices.': 'Clean Ethiopia is a digital initiative by the Environmental Protection Authority (EPA) designed to make environmental protection accessible to everyone. Our goal is simple — to empower citizens to report pollution, illegal waste disposal, deforestation, and other environmental violations directly from their mobile devices.',
    'We believe that protecting the environment starts with awareness and participation. Through technology, Clean Ethiopia connects the public with the Environmental Protection Authority, ensuring that every report is seen, tracked, and acted upon.': 'We believe that protecting the environment starts with awareness and participation. Through technology, Clean Ethiopia connects the public with the Environmental Protection Authority, ensuring that every report is seen, tracked, and acted upon.',
    'Our system promotes:': 'Our system promotes:',
    'Transparency — Every report is traceable from submission to resolution.': 'Transparency — Every report is traceable from submission to resolution.',
    'Accountability — Each action is logged and monitored to ensure proper follow-up.': 'Accountability — Each action is logged and monitored to ensure proper follow-up.',
    'Community Engagement — Citizens, communities, and institutions collaborate to keep Ethiopia clean and green.': 'Community Engagement — Citizens, communities, and institutions collaborate to keep Ethiopia clean and green.',
    'Clean Ethiopia is part of the nation’s effort to build a sustainable, safe, and environmentally responsible future for all Ethiopians. Together, we can create a cleaner and greener Ethiopia — one report at a time.': 'Clean Ethiopia is part of the nation’s effort to build a sustainable, safe, and environmentally responsible future for all Ethiopians. Together, we can create a cleaner and greener Ethiopia — one report at a time.',
    'Office': 'Office',
    'No offices match that search.': 'No offices match that search.',
    'PHONE': 'PHONE',
    'EMAIL': 'EMAIL',
    'Privacy Policy': 'Privacy Policy',
    'Clean Ethiopia ("we," "our," "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard the information you provide when using our mobile application or web system. By using this app, you agree to the terms of this Privacy Policy.': 'Clean Ethiopia ("we," "our," "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard the information you provide when using our mobile application or web system. By using this app, you agree to the terms of this Privacy Policy.',
    '2. Information We Collect': '2. Information We Collect',
    'Personal Information: such as your name, phone number, and location (when provided).': 'Personal Information: such as your name, phone number, and location (when provided).',
    'Report Details: description, media uploads (photo, video, audio, or documents).': 'Report Details: description, media uploads (photo, video, audio, or documents).',
    'Location Data: if you enable GPS to help identify environmental violation sites.': 'Location Data: if you enable GPS to help identify environmental violation sites.',
    'Device Information: including device type and operating system (for app performance).': 'Device Information: including device type and operating system (for app performance).',
    '3. How We Use Your Information': '3. How We Use Your Information',
    'Process and manage your environmental violation reports.': 'Process and manage your environmental violation reports.',
    'Communicate updates about the status of your reports.': 'Communicate updates about the status of your reports.',
    'Improve our service, system performance, and reporting accuracy.': 'Improve our service, system performance, and reporting accuracy.',
    'Generate anonymized analytics to support research and decision-making.': 'Generate anonymized analytics to support research and decision-making.',
    '4. Information Sharing': '4. Information Sharing',
    'Your personal data will not be shared with unauthorized parties. Data may only be shared with authorized EPA departments and stakeholders involved in report investigation, and law enforcement agencies when required by law.': 'Your personal data will not be shared with unauthorized parties. Data may only be shared with authorized EPA departments and stakeholders involved in report investigation, and law enforcement agencies when required by law.',
    '5. Data Security': '5. Data Security',
    'We apply security measures such as encryption, role-based access, and audit logs to protect your data from unauthorized access, loss, or misuse.': 'We apply security measures such as encryption, role-based access, and audit logs to protect your data from unauthorized access, loss, or misuse.',
    '6. User Choices': '6. User Choices',
    'You can choose to report anonymously. You can request data deletion or correction by contacting us at: [support@epa.gov.et]': 'You can choose to report anonymously. You can request data deletion or correction by contacting us at: [support@epa.gov.et]',
    '7. Policy Updates': '7. Policy Updates',
    'We may update this Privacy Policy occasionally. Changes will be posted in the app with a revised "Effective Date."': 'We may update this Privacy Policy occasionally. Changes will be posted in the app with a revised "Effective Date."',
    'Term and Conditions': 'Term and Conditions',
    'Effective Date: [Month, Day, Year]': 'Effective Date: [Month, Day, Year]',
    'Welcome to the Clean Ethiopia App. Please read these Terms and Conditions carefully before using our services.': 'Welcome to the Clean Ethiopia App. Please read these Terms and Conditions carefully before using our services.',
    'Acceptance of Terms': 'Acceptance of Terms',
    'By accessing or using the Clean Ethiopia application, you agree to comply with these Terms and all applicable laws and regulations. If you do not agree, please do not use the application.': 'By accessing or using the Clean Ethiopia application, you agree to comply with these Terms and all applicable laws and regulations. If you do not agree, please do not use the application.',
    'Purpose of the App': 'Purpose of the App',
    'This app is designed to help citizens report environmental violations such as pollution, illegal dumping, and deforestation. EPA staff will review, verify, and take necessary action based on the reports submitted.': 'This app is designed to help citizens report environmental violations such as pollution, illegal dumping, and deforestation. EPA staff will review, verify, and take necessary action based on the reports submitted.',
    'User Responsibilities': 'User Responsibilities',
    'By using this app, you agree to:': 'By using this app, you agree to:',
    'Provide accurate and truthful information.': 'Provide accurate and truthful information.',
    'Avoid uploading harmful, false, or illegal content.': 'Avoid uploading harmful, false, or illegal content.',
    'Respect other users and public privacy.': 'Respect other users and public privacy.',
    'Use the platform only for environmental reporting purposes.': 'Use the platform only for environmental reporting purposes.',
    'Prohibited Actions': 'Prohibited Actions',
    'You are strictly prohibited from:': 'You are strictly prohibited from:',
    'Submitting false or misleading reports.': 'Submitting false or misleading reports.',
    'Misusing the app for political or personal disputes.': 'Misusing the app for political or personal disputes.',
    'Uploading offensive, violent, or copyrighted material.': 'Uploading offensive, violent, or copyrighted material.',
    'Intellectual Property': 'Intellectual Property',
    'All design, content, and software used in the Clean Ethiopia app are property of the Environmental Protection Authority. You may not copy, modify, or redistribute without written permission.': 'All design, content, and software used in the Clean Ethiopia app are property of the Environmental Protection Authority. You may not copy, modify, or redistribute without written permission.',
    'Limitation of Liability': 'Limitation of Liability',
    'The Environmental Protection Authority is not responsible for:': 'The Environmental Protection Authority is not responsible for:',
    'Technical issues or service interruptions.': 'Technical issues or service interruptions.',
    'Actions taken by third parties based on submitted reports.': 'Actions taken by third parties based on submitted reports.',
    'Any loss or damage arising from misuse of the app.': 'Any loss or damage arising from misuse of the app.',
    'Account and Data': 'Account and Data',
    'You are responsible for keeping your login details secure. If you suspect unauthorized access, notify the support team immediately.': 'You are responsible for keeping your login details secure. If you suspect unauthorized access, notify the support team immediately.',
    'Contact': 'Contact',
    'For questions about these Terms, please contact the Environmental Protection Authority through the Contact Us option in the Settings screen.': 'For questions about these Terms, please contact the Environmental Protection Authority through the Contact Us option in the Settings screen.',
}

am_keys = {
    k: k for k in en_keys
}

am_keys.update({
    'About Us': 'ስለ እኛ',
    '1. Introduction': '1. መግቢያ',
    'No offices match that search.': 'ለፍለጋዎ የሚመጥን ቢሮ አልተገኘም።',
    'PHONE': 'ስልክ',
    'EMAIL': 'ኢሜይል',
    'Office': 'ቢሮ',
    'Privacy Policy': 'የግላዊነት መመሪያ',
    '2. Information We Collect': '2. የምንሰበስበው መረጃ',
    '3. How We Use Your Information': '3. መረጃዎን እንዴት እንደምንጠቀም',
    '4. Information Sharing': '4. መረጃ ማጋራት',
    '5. Data Security': '5. የውሂብ ደህንነት',
    '6. User Choices': '6. የተጠቃሚ ምርጫዎች',
    '7. Policy Updates': '7. የመመሪያ ዝማኔዎች',
    'Term and Conditions': 'የአገልግሎት ውሎች',
    'Acceptance of Terms': 'የውሎች መቀበል',
    'Purpose of the App': 'የመተግበሪያው ዓላማ',
    'User Responsibilities': 'የተጠቃሚ ኃላፊነቶች',
    'Prohibited Actions': 'የተከለከሉ ድርጊቶች',
    'Intellectual Property': 'አእምሯዊ ንብረት',
    'Limitation of Liability': 'የኃላፊነት ገደብ',
    'Account and Data': 'መለያ እና ውሂብ',
    'Contact': 'አድራሻ',
})

om_keys = {
    k: k for k in en_keys
}

om_keys.update({
    'About Us': 'Waa\'ee keenya',
    '1. Introduction': '1. Seensa',
    'No offices match that search.': 'Waajjirri barbaacha kanaan wal simu hin jiru.',
    'PHONE': 'BILBILA',
    'EMAIL': 'IMEELII',
    'Office': 'Waajjira',
    'Privacy Policy': 'Imaammata Dhuunfaa',
    '2. Information We Collect': '2. Odeeffannoo Nuti Funaannu',
    '3. How We Use Your Information': '3. Odeeffannoo Kee Akkamitti Akka Fayyadamnu',
    '4. Information Sharing': '4. Odeeffannoo Qooduu',
    '5. Data Security': '5. Nageenya Daataa',
    '6. User Choices': '6. Filannoo Fayyadamaa',
    '7. Policy Updates': '7. Haaromsa Imaammataa',
    'Term and Conditions': 'Haalaafi Dambiiwwan',
    'Acceptance of Terms': 'Haalota Fudhachuu',
    'Purpose of the App': 'Kaayyoo Appiliikeeshinichaa',
    'User Responsibilities': 'Itti Gaafatamummaa Fayyadamaa',
    'Prohibited Actions': 'Gochoota Dhowwaman',
    'Intellectual Property': 'Qabeenya Sammuu',
    'Limitation of Liability': 'Daangaa Itti Gaafatamummaa',
    'Account and Data': 'Akkaawuntii fi Daataa',
    'Contact': 'Quunnamtii',
})

so_keys = {
    k: k for k in en_keys
}

so_keys.update({
    'About Us': 'Nagu saabsan',
    '1. Introduction': '1. Hordhac',
    'No offices match that search.': 'Ma jiro xafiis la mid ah baaritaankaas.',
    'PHONE': 'TELEFOONKA',
    'EMAIL': 'IIMAYL',
    'Office': 'Xafiiska',
    'Privacy Policy': 'Qaanuunka Arrimaha Khaaska ah',
    '2. Information We Collect': '2. Macluumaadka Aan Uruurino',
    '3. How We Use Your Information': '3. Sida Aan U Isticmaalno Macluumaadkaaga',
    '4. Information Sharing': '4. Wadaagista Macluumaadka',
    '5. Data Security': '5. Amniga Xogta',
    '6. User Choices': '6. Doorashooyinka Isticmaalaha',
    '7. Policy Updates': '7. Cusboonaysiinta Qaanuunka',
    'Term and Conditions': 'Shuruudaha iyo Xaaladaha',
    'Acceptance of Terms': 'Aqbalaadda Shuruudaha',
    'Purpose of the App': 'Ujeedada App-ka',
    'User Responsibilities': 'Waajibaadka Isticmaalaha',
    'Prohibited Actions': 'Falalka Mamnuuca ah',
    'Intellectual Property': 'Hantida Maskaxda',
    'Limitation of Liability': 'Xadaynta Masuuliyadda',
    'Account and Data': 'Koontada iyo Xogta',
    'Contact': 'Xiriir',
})

def dict_to_dart_entries(d):
    entries = []
    for k, v in d.items():
        ks = k.replace("'", "\\'")
        vs = v.replace("'", "\\'")
        entries.append(f"    '{ks}': '{vs}',")
    return "\n".join(entries) + "\n"

path = r'c:\Users\lenovo\Documents\AI Institute\EPRS-Clean-Ethiopia-App\eprs\lib\core\constants\languages\app_translations.dart'
with io.open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Insert for EN
# Find end of _en (which ends before _am starts)
en_insert_pos = content.find('  static const Map<String, String> _am = {')
en_end = content.rfind('};', 0, en_insert_pos)
content = content[:en_end] + dict_to_dart_entries(en_keys) + content[en_end:]

am_insert_pos = content.find('  static const Map<String, String> _om = {')
am_end = content.rfind('};', 0, am_insert_pos)
content = content[:am_end] + dict_to_dart_entries(am_keys) + content[am_end:]

om_insert_pos = content.find('  static const Map<String, String> _soLegacy = {')
om_end = content.rfind('};', 0, om_insert_pos)
content = content[:om_end] + dict_to_dart_entries(om_keys) + content[om_end:]

so_end = content.rfind('};', om_insert_pos)
content = content[:so_end] + dict_to_dart_entries(so_keys) + content[so_end:]

with io.open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Translations injected successfully!")
