export default class Logger {
  constructor(scope = null) {
    this.scope = scope;
  }

  log(...args) {
    return console.log(...this._buildArgs("log", args));
  }

  info(...args) {
    return console.info(...this._buildArgs("info", args));
  }

  debug(...args) {
    return console.debug(...this._buildArgs("debug", args));
  }

  warn(...args) {
    return console.warn(...this._buildArgs("warn", args));
  }

  error(...args) {
    return console.error(...this._buildArgs("error", args));
  }

  _buildArgs(level, args) {
    let prefix = "[LOOKBOOK]";
    if (this.scope) {
      prefix += ` ${this.scope}:`;
    }
    return [prefix, ...args];
  }
}