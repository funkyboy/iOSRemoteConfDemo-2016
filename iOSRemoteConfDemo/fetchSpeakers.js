var speakerTags = document.querySelectorAll('.item')

speakers = []

for (var i = 0; i < speakerTags.length; i++) {
    var speaker = speakerTags[i]
    var avatarURL = speaker.querySelector('.picture img').getAttribute('src')
    var name = speaker.querySelector('.speaker_info h3').textContent
    speakers.push({"speakerName" : name, "avatarURL" : avatarURL})
}

webkit.messageHandlers.didFetchSpeakers.postMessage(speakers)