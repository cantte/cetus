import { buttonVariants } from "@cetus/ui/components/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@cetus/ui/components/card"
import { createFileRoute } from "@tanstack/react-router"
import { Clock3, Hammer, Sparkles } from "lucide-react"

export const Route = createFileRoute("/")({
  component: HomeComponent,
})

function HomeComponent() {
  return (
    <main className="flex min-h-full items-center justify-center bg-background px-4 py-10">
      <div className="flex w-full max-w-3xl flex-col gap-6">
        <div className="flex items-center gap-2 text-xs font-medium text-muted-foreground">
          <span className="inline-flex size-2 rounded-full bg-primary" />
          Cetus
        </div>

        <Card>
          <CardHeader className="gap-4">
            <div className="flex size-12 items-center justify-center rounded-none border bg-muted text-foreground">
              <Hammer aria-hidden="true" />
            </div>
            <div className="flex flex-col gap-2">
              <CardTitle className="text-3xl font-semibold tracking-normal">
                Estamos construyendo esta experiencia
              </CardTitle>
              <CardDescription className="max-w-2xl text-base">
                Cetus se encuentra en desarrollo. Estamos afinando los detalles
                para ofrecerte una plataforma estable, clara y lista para
                trabajar.
              </CardDescription>
            </div>
          </CardHeader>

          <CardContent className="flex flex-col gap-6">
            <div className="grid gap-3 sm:grid-cols-2">
              <div className="flex gap-3 rounded-none border bg-background p-4">
                <Sparkles aria-hidden="true" className="mt-0.5 shrink-0" />
                <div className="flex flex-col gap-1">
                  <h2 className="font-medium">Diseño en progreso</h2>
                  <p className="text-muted-foreground">
                    Pronto tendrás acceso a las funciones principales y a una
                    navegación más completa.
                  </p>
                </div>
              </div>
              <div className="flex gap-3 rounded-none border bg-background p-4">
                <Clock3 aria-hidden="true" className="mt-0.5 shrink-0" />
                <div className="flex flex-col gap-1">
                  <h2 className="font-medium">Lanzamiento en preparación</h2>
                  <p className="text-muted-foreground">
                    Mientras tanto, seguimos validando la experiencia para que
                    todo funcione como esperas.
                  </p>
                </div>
              </div>
            </div>

            <div className="flex flex-col gap-3 border-t pt-5 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-muted-foreground">
                Gracias por tu paciencia. Vuelve pronto para ver las novedades.
              </p>
              <a
                href="mailto:hello@cetus.dev"
                className={buttonVariants({ className: "self-start" })}
              >
                Contactar al equipo
              </a>
            </div>
          </CardContent>
        </Card>
      </div>
    </main>
  )
}
