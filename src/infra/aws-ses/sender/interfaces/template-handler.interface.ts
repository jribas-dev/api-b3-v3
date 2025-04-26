export interface TemplateHandler<TContext> {
  /**
   * Gera HTML com base no contexto fornecido
   */
  buildHtml(context: TContext): string;
}
