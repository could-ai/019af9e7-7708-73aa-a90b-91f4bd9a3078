import "jsr:@supabase/functions-js/edge-runtime.d.ts"

Deno.serve(async (req) => {
  const { text, sourceLang, targetLang } = await req.json()
  const apiKey = Deno.env.get('OPENAI_API_KEY')

  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: 'OPENAI_API_KEY not set in Supabase Secrets' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }

  try {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: `You are a helpful translation assistant. Translate the following text ${sourceLang && sourceLang !== "Auto" ? "from " + sourceLang + " " : ""}to ${targetLang}. Only return the translated text, no explanations.`
          },
          {
            role: 'user',
            content: text
          }
        ],
        temperature: 0.3,
      }),
    })

    const data = await response.json()
    return new Response(
      JSON.stringify(data),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
