module.exports = async (req, res) => {
  res.setHeader("Cache-Control", "no-store");

  if (req.method !== "POST") {
    res.status(405).json({ success: false });
    return;
  }

  const secret = process.env.RECAPTCHA_SECRET_KEY;
  const token = req.body && req.body.token;

  if (!secret || !token) {
    res.status(200).json({ success: false });
    return;
  }

  try {
    const params = new URLSearchParams({ secret, response: token });
    const r = await fetch("https://www.google.com/recaptcha/api/siteverify", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: params,
    });
    const data = await r.json();
    res.status(200).json({ success: !!data.success });
  } catch (e) {
    res.status(200).json({ success: false });
  }
};
