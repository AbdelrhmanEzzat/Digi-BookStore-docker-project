#hello
# ─── Stage 1: Builder ────────────────────────────────────
FROM python:3.11-alpine AS builder
WORKDIR /build
RUN apk add --no-cache gcc musl-dev libpq-dev
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# ─── Stage 2: Runtime (lightweight) ──────────────────────
FROM python:3.11-alpine AS runtime
RUN apk add --no-cache libpq wget

# Non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /root/.local /home/appuser/.local
ENV PATH=/home/appuser/.local/bin:$PATH

# Copy application code
COPY flask_app.py .
COPY static/ ./static/

# Fix ownership
RUN chown -R appuser:appgroup /app

USER appuser
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD wget -qO- http://localhost:8000/api/health || exit 1

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8000", "flask_app:app"]
