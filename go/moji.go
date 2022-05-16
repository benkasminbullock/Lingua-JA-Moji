package moji

func KataHira(kata rune) rune {
	/* Katakana to hiragana */
	if kata >= 0x30a0 && kata <= 0x30ff {
		kata -= 0x60
	}
	return kata
}

func Romaji(kana string) (romaji string) {
	runes := []rune(kana)
	for _, r := range runes {
		r = KataHira(r)
		romaji += Consonant[r] + Vowel[r]
	}
	return romaji
}
