package com.example.fitness_pro

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.Voice
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class DeviceTts(private val activity: Activity) : MethodChannel.MethodCallHandler {
    private var tts: TextToSpeech? = null
    private var initializing = false
    private var generation = 0
    private var pending: MethodChannel.Result? = null
    private val prefs = activity.getSharedPreferences("voice_options", Activity.MODE_PRIVATE)
    private val handler = Handler(Looper.getMainLooper())

    private fun naturalVoice(engine: TextToSpeech): Voice? {
        val locale = engine.voice?.locale ?: Locale.getDefault()
        return engine.voices?.filter {
            it.locale.language == locale.language &&
                (locale.country.isEmpty() || it.locale.country == locale.country) &&
                it.quality >= Voice.QUALITY_HIGH &&
                !it.features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)
        }?.maxWithOrNull(compareBy<Voice> { it.quality }.thenBy { !it.isNetworkConnectionRequired })
    }

    private fun initialize(packageName: String?, result: MethodChannel.Result, ready: (TextToSpeech) -> Unit) {
        if (initializing) { result.error("busy", "Voice engine is starting. Please try again.", null); return }
        initializing = true
        pending = result
        tts?.shutdown()
        tts = null
        val token = ++generation
        handler.postDelayed({
            if (token == generation && initializing) {
                initializing = false
                generation++
                tts?.shutdown()
                tts = null
                pending = null
                result.error("tts_timeout", "The voice engine did not respond. Install or select another TTS engine.", null)
            }
        }, 10000)
        val listener = TextToSpeech.OnInitListener { status ->
            if (token != generation) return@OnInitListener
            initializing = false
            pending = null
            val engine = tts
            if (status != TextToSpeech.SUCCESS || engine == null) {
                engine?.shutdown()
                tts = null
                result.error("tts_unavailable", "No working TTS engine was found. Download or enable one to test your voice.", null)
            } else {
                try {
                    val language = prefs.getString("language", "") ?: ""
                    if (language.isNotEmpty()) engine.setLanguage(Locale.forLanguageTag(language))
                    if (prefs.getBoolean("natural", false)) naturalVoice(engine)?.let { engine.voice = it }
                    ready(engine)
                } catch (error: Exception) { result.error("tts_error", error.message, null) }
            }
        }
        try {
            tts = if (packageName.isNullOrEmpty()) TextToSpeech(activity, listener) else TextToSpeech(activity, listener, packageName)
        } catch (error: Exception) {
            initializing = false
            generation++
            pending = null
            result.error("tts_unavailable", error.message, null)
        }
    }

    private fun state(engine: TextToSpeech): Map<String, Any> {
        val packageName = prefs.getString("engine", null) ?: engine.defaultEngine ?: ""
        val engines = engine.engines.map { mapOf("id" to it.name, "label" to it.label) }
        val language = prefs.getString("language", "") ?: ""
        return mapOf(
            "engine" to packageName,
            "engineLabel" to (engine.engines.find { it.name == packageName }?.label ?: packageName),
            "engines" to engines,
            "language" to language,
            "languageLabel" to (if (language.isEmpty()) "Default" else Locale.forLanguageTag(language).getDisplayName(Locale.getDefault())),
            "languages" to (engine.availableLanguages ?: emptySet()).sortedBy { it.getDisplayName(Locale.getDefault()) }
                .map { mapOf("id" to it.toLanguageTag(), "label" to it.getDisplayName(Locale.getDefault())) },
            "naturalAvailable" to (naturalVoice(engine) != null),
            "natural" to (prefs.getBoolean("natural", false) && engine.voice?.name == naturalVoice(engine)?.name)
        )
    }

    private fun launch(intent: Intent, result: MethodChannel.Result) {
        try { activity.startActivity(intent); result.success(null) }
        catch (_: android.content.ActivityNotFoundException) { result.error("not_available", "This engine or settings page is not available on your device.", null) }
        catch (_: SecurityException) { result.error("not_available", "Android did not allow this voice settings page to open.", null) }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "stop" -> { tts?.stop(); result.success(null) }
            "openSettings" -> launch(Intent("com.android.settings.TTS_SETTINGS"), result)
            "installEngine" -> {
                val store = Intent(Intent.ACTION_VIEW, Uri.parse("market://search?q=text%20to%20speech&c=apps"))
                try { activity.startActivity(store); result.success(null) }
                catch (_: android.content.ActivityNotFoundException) {
                    launch(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/search?q=text%20to%20speech&c=apps")), result)
                }
            }
            "installLanguage" -> {
                val intent = Intent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA)
                (prefs.getString("engine", null) ?: tts?.defaultEngine)?.let { intent.setPackage(it) }
                launch(intent, result)
            }
            "setEngine" -> {
                val packageName = call.arguments as? String
                if (packageName.isNullOrEmpty()) { result.error("invalid_engine", "Select a voice engine.", null); return }
                initialize(packageName, result) {
                    prefs.edit().putString("engine", packageName).apply()
                    result.success(null)
                }
            }
            "refresh" -> initialize(prefs.getString("engine", null), result) { result.success(state(it)) }
            else -> {
                val engine = tts
                if (initializing) { result.error("busy", "Voice engine is starting. Please try again.", null) }
                else if (engine == null) initialize(prefs.getString("engine", null), result) { perform(it, call, result) }
                else perform(engine, call, result)
            }
        }
    }

    private fun perform(engine: TextToSpeech, call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "getState" -> result.success(state(engine))
                "speak" -> {
                    val text = call.argument<String>("text")?.trim().orEmpty()
                    if (text.isEmpty()) { result.error("invalid_text", "Speech text is empty.", null); return }
                    val params = Bundle().apply { putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, (call.argument<Double>("volume") ?: 0.8).coerceIn(0.0, 1.0).toFloat()) }
                    if (engine.speak(text, TextToSpeech.QUEUE_FLUSH, params, "workout-coaching") == TextToSpeech.ERROR) {
                        result.error("speak_failed", "Could not speak this workout cue.", null)
                    } else result.success(null)
                }
                "testVoice" -> {
                    if (engine.speak("Get ready for your workout. Let's make today a great day!", TextToSpeech.QUEUE_FLUSH, null, "voice-preview") == TextToSpeech.ERROR) {
                        result.error("speak_failed", "Could not play this voice. Download the language data or select another engine.", null)
                    } else result.success(null)
                }
                "setLanguage" -> {
                    val code = call.arguments as? String ?: ""
                    val locale = if (code.isEmpty()) Locale.getDefault() else Locale.forLanguageTag(code)
                    val status = engine.isLanguageAvailable(locale)
                    if (status < TextToSpeech.LANG_AVAILABLE) {
                        result.error("missing_language", "This language is unavailable. Download its TTS language data first.", null)
                    } else {
                        engine.setLanguage(locale)
                        prefs.edit().putString("language", code).putBoolean("natural", false).apply()
                        result.success(null)
                    }
                }
                "setNatural" -> {
                    if (call.arguments == true) {
                        val voice = naturalVoice(engine)
                        if (voice == null) { result.error("missing_voice", "No high-quality voice is installed for this language. Download more voice data first.", null) }
                        else if (engine.setVoice(voice) == TextToSpeech.ERROR) { result.error("voice_failed", "Could not select this voice.", null) }
                        else { prefs.edit().putBoolean("natural", true).apply(); result.success(null) }
                    } else {
                        engine.setLanguage(engine.voice?.locale ?: Locale.getDefault())
                        prefs.edit().putBoolean("natural", false).apply()
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        } catch (error: Exception) { result.error("tts_error", error.message, null) }
    }

    fun close() {
        generation++
        pending?.error("closed", "Voice engine was closed.", null)
        pending = null
        tts?.stop()
        tts?.shutdown()
        tts = null
        handler.removeCallbacksAndMessages(null)
    }
}
